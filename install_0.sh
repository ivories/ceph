#!/bin/bash

#Create a keyring for your cluster and generate a monitor secret key
ceph-authtool --create-keyring ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'

#Generate an administrator keyring, generate a client.admin user and add the user to the keyring
ceph-authtool --create-keyring ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

#Generate a bootstrap-osd keyring, generate a client.bootstrap-osd user and add the user to the keyring
ceph-authtool --create-keyring ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'

#Add the generated keys to the ceph.mon.keyring
ceph-authtool ceph.mon.keyring --import-keyring ceph.client.admin.keyring
ceph-authtool ceph.mon.keyring --import-keyring ceph.keyring

#Change the owner for ceph.mon.keyring
chown ceph:ceph ceph.mon.keyring

cp example.hosts.txt hosts.txt
cp example.ceph.conf ceph.conf


systemctl disable --now firewalld
sed -i 's/SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config
wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
cat > /etc/apt/sources.list << EOF
deb http://cn.archive.ubuntu.com/ubuntu focal main restricted
deb http://cn.archive.ubuntu.com/ubuntu focal-updates main restricted
deb http://cn.archive.ubuntu.com/ubuntu focal universe
deb http://cn.archive.ubuntu.com/ubuntu focal-updates universe
deb http://cn.archive.ubuntu.com/ubuntu focal multiverse
deb http://cn.archive.ubuntu.com/ubuntu focal-updates multiverse
deb http://cn.archive.ubuntu.com/ubuntu focal-backports main restricted universe multiverse
deb http://cn.archive.ubuntu.com/ubuntu focal-security main restricted
deb http://cn.archive.ubuntu.com/ubuntu focal-security universe
deb http://cn.archive.ubuntu.com/ubuntu focal-security multiverse
deb https://download.ceph.com/debian-quincy/ focal main
EOF

apt update && apt install -y python3.9 && apt remove -y python3.10 python3-minimal libpython3-stdlib libnl-3-200
apt autoremove
apt install -y ceph chrony netplan.io

