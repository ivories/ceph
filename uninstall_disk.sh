#!/bin/bash

for i in $(cat hosts.txt); do
    DISKS=$(ssh ${i} "lsblk -dp | grep -v /boot | grep -o '^/dev/sd[^ ]*' | grep -v /dev/sda")
    echo host:${i},disks:${DISKS}
    for DISK in $DISKS; do
        ssh ${i} "sudo parted -s ${DISK}"
        ssh ${i} "sudo sgdisk --zap-all ${DISK}"
        ssh ${i} "dd if=/dev/zero of=${DISK} bs=512k count=1"
    done

    DISKS=$(ssh ${i} "lsblk -dp | grep -v /boot | grep -o '^/dev/nvme[^ ]*' | grep -v /dev/sda")
    echo host:${i},disks:${DISKS}
    for DISK in $DISKS; do
        ssh ${i} "sudo parted -s ${DISK}"
        ssh ${i} "sudo sgdisk --zap-all ${DISK}"
        ssh ${i} "dd if=/dev/zero of=${DISK} bs=512k count=1"
    done

done


