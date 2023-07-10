#!/bin/bash
CLUSTERID=3c6ea1f1-7823-45cf-b4ac-556955ca91ab
ADDMONS=""

# 从hosts.txt中读取主机名
hosts=( $(cat hosts.txt) )

mon_initial_members=""
mon_host=""

# 获取对应的IP地址并添加到mon_initial_members和mon_host中
for host in "${hosts[@]}"; do
    ip=$(grep "$host" /etc/hosts | awk '{print $1}')
    mon_initial_members+="$host,"
    mon_host+="$ip,"
done

# 去掉最后的逗号
mon_initial_members=${mon_initial_members%?}
mon_host=${mon_host%?}

# 构建新的mds字符串
mds_str=""
for host in "${hosts[@]}"; do
    mds_str+="\n[mds.$host]\nhost = $host\n"
done

# 更新ceph.conf
cp example.ceph.conf ceph.conf
sed -i "s/^mon_initial_members = .*/mon_initial_members = $mon_initial_members/" ./ceph.conf
sed -i "s/^mon_host = .*/mon_host = $mon_host/" ./ceph.conf
sed -i "s/@@@mds@@@/$mds_str/" ./ceph.conf


rm -rf monmap
monmaptool --create --fsid ${CLUSTERID} monmap

for i in $(cat hosts.txt);do
    IP=$(grep $i /etc/hosts|sort|uniq|awk '{print $1}')
    COMMANDP=" --add ${i} ${IP} "
    echo $COMMANDP
    monmaptool ${COMMANDP} monmap
    scp /etc/hosts ${i}:/etc/hosts
    scp /root/.ssh/authorized_keys ${i}:/root/.ssh/authorized_keys
done

for i in $(cat hosts.txt);do
	ssh ${i} "systemctl stop ceph-mon@${i};"
	ssh ${i} "rm -rf /var/lib/ceph/mon/"
	ssh ${i} "rm -rf /tmp/monmap"
	scp monmap ${i}:/tmp
	scp ceph.conf ${i}:/etc/ceph
	scp ceph.client.admin.keyring ${i}:/etc/ceph
	A=$(ssh ${i} mount |grep ceph|awk '{print $3}')
	ssh ${i} "rm -f /tmp/ceph.mon.keyring"
	scp ceph.mon.keyring ${i}:/tmp
	ssh ${i} "chown ceph:ceph /tmp/ceph.mon.keyring /tmp/monmap"
	ssh ${i} "sudo -u ceph mkdir -p /var/lib/ceph/mon/ceph-${i}"
	ssh ${i} "sudo -u ceph ceph-mon --mkfs -i ${i} --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring"
	ssh ${i} "sudo -u ceph ceph-mon -i ${i} --inject-monmap /tmp/monmap"
	ssh ${i} "systemctl enable ceph-mon@${i};sleep 2;systemctl start ceph-mon@${i}"
done

ssh ${i} "ceph mon enable-msgr2"
