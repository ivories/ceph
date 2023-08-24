#!/bin/bash

ID=$1

if [ -z "$1" ];then
    echo "PLEASE input ./uninstall_osd.sh 1"
    exit
fi

ceph osd out osd.${ID}
systemctl stop ceph-osd@${ID}.service
ceph osd crush remove osd.${ID}
ceph osd rm osd.${ID}
ceph auth del osd.${ID}
