#!/bin/bash
POOLNUM=512
ceph osd pool create fs_db_data ${POOLNUM}
ceph osd pool create fs_db_metadata ${POOLNUM}
ceph osd lspools
ceph fs new cephfs fs_db_metadata fs_db_data
