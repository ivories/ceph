#!/bin/bash

for i in $(cat hosts.txt);do
	echo "start ${i}"
	ssh ${i} "mkdir -p /var/lib/ceph/mgr/ceph-${i}"
	scp ceph.keyring ${i}:/var/lib/ceph/mgr/ceph-${i}/keyring
	ssh ${i} "chown -R ceph:ceph /var/lib/ceph/mgr/"
	ssh ${i} "ceph auth get-or-create mgr.${i} mon 'allow profile mgr' osd 'allow *' mds 'allow *'>/var/lib/ceph/mgr/ceph-${i}/keyring"
	ssh ${i} "systemctl restart ceph-mgr@${i};systemctl enable ceph-mgr@${i}"
	echo "end ${i}"
done
