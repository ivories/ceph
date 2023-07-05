ceph fs fail cephfs
ceph fs rm cephfs --yes-i-really-mean-it
ceph osd pool delete fs_db_data fs_db_data --yes-i-really-really-mean-it
ceph osd pool delete fs_db_metadata fs_db_metadata --yes-i-really-really-mean-it

