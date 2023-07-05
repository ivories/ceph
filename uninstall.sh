#!/bin/bash

for i in $(cat hosts.txt); do
    ssh ${i} "systemctl stop ceph-osd.target"
    DISKS=$(ssh ${i} "lsblk -dp | grep -v /boot | grep -o '^/dev/sd[^ ]*' | grep -v /dev/sda")
    for DISK in $DISKS; do
        ssh ${i} "sudo parted -s ${DISK}"
        ssh ${i} "sudo sgdisk --zap-all ${DISK}"
        ssh ${i} "dd if=/dev/zero of=${DISK} bs=512k count=1"
    done
    ssh ${i} "systemctl stop ceph-mgr.target"
    ssh ${i} "systemctl stop ceph-mon.target"
    ssh ${i} "systemctl stop ceph.target"
    ssh ${i} "rm -rf /var/lib/ceph/*"
done


