#!/bin/bash
CLUSTERID=3c6ea1f1-7823-45cf-b4ac-556955ca91ab
ADDMONS=""

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
