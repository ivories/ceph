#!/bin/bash
#Create a keyring for your cluster and generate a monitor secret key
ceph-authtool --create-keyring ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'

#Generate an administrator keyring, generate a client.admin user and add the user to the keyring
ceph-authtool --create-keyring ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

#Generate a bootstrap-osd keyring, generate a client.bootstrap-osd user and add the user to the keyring
ceph-authtool --create-keyring ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'

#Add the generated keys to the ceph.mon.keyring
ceph-authtool ceph.mon.keyring --import-keyring ceph.client.admin.keyring
ceph-authtool ceph.mon.keyring --import-keyring ceph.keyring

#Change the owner for ceph.mon.keyring
chown ceph:ceph ceph.mon.keyring

cp example.hosts.txt hosts.txt
cp example.ceph.conf ceph.conf
