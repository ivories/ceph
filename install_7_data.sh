#!/bin/bash

# mount.ceph c01:6789,c02:6789,c03:6789,c04:6789,c05:6789,c06:6789:/ /root/data -o rw,name=admin,secret=AQAtG6ZkrYsqCBAAR6IY+fuqImCuYFpBCy478A==

KEYRING="AQAtG6ZkrYsqCBAAR6IY+fuqImCuYFpBCy478A=="
echo "c01:6789,c02:6789,c03:6789,c04:6789,c05:6789,c06:6789:/	/root/data ceph rw,name=admin,secret=${KEYRING},_netdev 0 0" >> /etc/fstab

