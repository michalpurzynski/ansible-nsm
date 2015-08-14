#!/bin/bash

cd /opt/bro/share/bro
tn=intelzilla-`date +'%y-%m-%d-%H-%M'`.tar.gz
tar cvfpz $tn intelzilla
cd /home/brozilla/intelzilla/bro
find . -type f | while read file; do
    cp "${file}" /opt/bro/share/bro/intelzilla/"${file}";
done
chown -R root:root /opt/bro/share/bro/intelzilla

