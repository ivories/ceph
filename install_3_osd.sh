#!/bin/bash
if [ -f osdid.txt ]; then
  OSDID=$(cat osdid.txt)
else
  OSDID=0
fi

for i in $(cat hosts.txt); do
    ssh ${i} "sudo -u ceph mkdir -p /var/lib/ceph/bootstrap-osd"
    scp ceph.keyring ${i}:/var/lib/ceph/bootstrap-osd/
    ssh ${i} "chown ceph:ceph -R /var/lib/ceph/bootstrap-osd/"
    DISKS=$(ssh ${i} "lsblk -dp | grep -v /boot | grep -o '^/dev/nvme[^ ]*' | grep -v /dev/sda")
    for DISK in $DISKS; do
        ssh ${i} "sudo -u ceph mkdir -p /var/lib/ceph/osd/ceph-${OSDID}"
        ssh ${i} "ceph-volume lvm create --data ${DISK}"
        ssh ${i} "systemctl restart ceph-osd@${OSDID};systemctl enable ceph-osd@${OSDID}"
        OSDID=$((OSDID+1))
    done
    DISKS=$(ssh ${i} "lsblk -dp | grep -v /boot | grep -o '^/dev/sd[^ ]*' | grep -v /dev/sda")
    for DISK in $DISKS; do
        ssh ${i} "sudo -u ceph mkdir -p /var/lib/ceph/osd/ceph-${OSDID}"
        ssh ${i} "ceph-volume lvm create --data ${DISK}"
        ssh ${i} "systemctl restart ceph-osd@${OSDID};systemctl enable ceph-osd@${OSDID}"
        OSDID=$((OSDID+1))
    done

done

echo $OSDID > osdid.txt
