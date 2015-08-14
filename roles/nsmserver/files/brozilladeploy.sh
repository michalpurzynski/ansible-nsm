#!/bin/bash

cd /opt/bro/share/bro
tn=brozilla-`date +'%y-%m-%d-%H-%M'`.tar.gz
tar cvfpz $tn brozilla
mv brozilla/__load__.bro .
rm -rf brozilla
cp -a /home/brozilla/brozilla/nsm-scripts brozilla
mv __load__.bro brozilla
chown -R root:root /opt/bro/share/bro/brozilla

