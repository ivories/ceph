#!/bin/bash

ceph osd getcrushmap -o 1.file
crushtool -d 1.file -o 1.txt
sed -i 's#host#osd#g' 1.txt
crushtool -c 1.txt -o 1.new
ceph osd setcrushmap -i 1.new
rm -rf 1.file 1.txt 1.new
