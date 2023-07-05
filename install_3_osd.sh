#!/bin/bash
OSDID=0

for i in $(cat hosts.txt); do
    ssh ${i} "sudo -u ceph mkdir -p /var/lib/ceph/bootstrap-osd"
    scp ceph.keyring ${i}:/var/lib/ceph/bootstrap-osd/
    ssh ${i} "chown ceph:ceph -R /var/lib/ceph/bootstrap-osd/"
    DISKS=$(ssh ${i} "lsblk -dp | grep -v /boot | grep -o '^/dev/sd[^ ]*' | grep -v /dev/sda")
    for DISK in $DISKS; do
	ssh ${i} "sudo parted -s ${DISK}"
	ssh ${i} "sudo sgdisk --zap-all ${DISK}"
        ssh ${i} "sudo -u ceph mkdir -p /var/lib/ceph/osd/ceph-${OSDID}"
        A=$(ssh ${i} vgdisplay | grep ceph | awk '{print $NF}')
        if [ "$A" != "" ]; then
            ssh ${i} "systemctl stop ceph-osd@${OSDID}"
            OLDOSDID=$(ssh ${i} "dmsetup status | grep ^ceph | awk -F ':' '{print \$1}'")
            if [ "${OLDOSDID}" != "" ]; then
                ssh ${i} "dmsetup remove ${OLDOSDID}"
            fi
            ssh ${i} "dd if=/dev/zero of=${DISK} bs=512k count=1"
        fi
        ssh ${i} "ceph-volume lvm create --data ${DISK}"
        ssh ${i} "systemctl restart ceph-osd@${OSDID};systemctl enable ceph-osd@${OSDID}"
        OSDID=$((OSDID+1))
    done
done


