#!/bin/bash
POOLNUM=512
ceph osd pool create fs_db_data ${POOLNUM}
ceph osd pool create fs_db_metadata ${POOLNUM}
ceph osd lspools
ceph fs new cephfs fs_db_metadata fs_db_data
ceph fs set cephfs max_mds 5

ceph auth add client.cephfs mon 'allow r' mds 'allow rw' osd 'allow rwx pool=cephfs'
ceph auth get client.cephfs -o /etc/ceph/ceph.client.cephfs.keyring
ceph auth print-key /etc/ceph/ceph.client.cephfs.keyring > /etc/ceph/cephfs.key

for i in $(cat hosts.txt);do
    scp /etc/ceph/cephfs.key ${i}:/etc/ceph/
done

