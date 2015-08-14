#!/bin/bash

dpkg -l linux-* | awk '/^ii/{ print $2}' | egrep -v `uname -r | cut -f1,2 -d"-"` | egrep '[0-9]' | egrep '(image|headers|tools)' | xargs sudo apt-get -y remove 2>&1 | mail mpurzynski@mozilla.com
