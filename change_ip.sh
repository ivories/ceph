#!/bin/bash

ceph mon getmap -o monmap
ceph-mon -i $(hostname) --extract-monmap monmap
monmaptool --rm $(hostname) monmap
monmaptool --add $(hostname) 192.168.5.15 monmap 
monmaptool --print monmap 
 
for i in $(cat hosts.txt);do
	ssh ${i} "systemctl stop ceph-mon@${i}"
        ssh ${i} "rm -rf /tmp/monmap"
        scp monmap ${i}:/tmp
	ssh ${i} "ceph-mon -i ${i} --inject-monmap /tmp/monmap"
        ssh ${i} "systemctl start ceph-mon@${i}"
done



