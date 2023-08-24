#!/bin/bash
for i in $(cat hosts_osd.txt); do
    ssh ${i} "systemctl restart ceph.target"
done

