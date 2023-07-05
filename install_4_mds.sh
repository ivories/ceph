#!/bin/bash

for i in $(cat hosts.txt);do
	ssh ${i} "rm -rf /var/lib/ceph/mds/"
	ssh ${i} "ceph auth del mds.${i}"
	ssh ${i} "ceph auth rm mds.${i}"
	ssh ${i} "sudo -u ceph mkdir -p /var/lib/ceph/mds/ceph-${i}"
	ssh ${i} "ceph-authtool --create-keyring /var/lib/ceph/mds/ceph-${i}/keyring --gen-key -n mds.${i}"
	ssh ${i} "chown ceph:ceph -R /var/lib/ceph/mds/ceph-${i}/"
	#ssh ${i} "ceph auth add mds.${i} osd 'allow rwx' mds 'allow' mon 'allow profile mds' -i /var/lib/ceph/mds/ceph-${i}/keyring"
	ssh ${i} "ceph auth get-or-create mds.${i} mon 'profile mds' mgr 'profile mds' mds 'allow *' osd 'allow *' > /var/lib/ceph/mds/ceph-${i}/keyring"
	ssh ${i} "systemctl restart ceph-mds@${i};systemctl enable ceph-mds@${i}"
done

ceph config set mon auth_allow_insecure_global_id_reclaim false
