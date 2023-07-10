#!/bin/bash

for i in $(cat hosts.txt);do
    ssh ${i} "systemctl disable --now firewalld"
    ssh ${i} "sed -i 's/SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config"
    ssh ${i} "wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -"
    ssh ${i} "cat > /etc/apt/sources.list << EOF
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
EOF"

#    ssh ${i} "apt-add-repository 'deb https://download.ceph.com/debian-quincy/ focal main'"
    ssh ${i} "apt update && apt install -y python3.9 && apt remove -y python3.10 python3-minimal libpython3-stdlib libnl-3-200"
    ssh ${i} "apt install -y ceph chrony"
done

