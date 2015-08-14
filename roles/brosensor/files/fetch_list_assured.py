#! /usr/bin/env python3
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Contributor(s):
# Michal Purzynski mpurzynski@mozilla.com

import os, sys
import json
import urllib.request
import shutil

listsandsizes = { 'iqrisk.ioc.addr.bro' : { 'url' : 'https://nsmserver1.private.scl3.mozilla.com/iqrisk.ioc.addr.bro', 'size' : 1000, 'path' : '/opt/bro/share/bro/intelzilla' },
                    'iqrisk.ioc.addr.suricata' : { 'url' : 'https://nsmserver1.private.scl3.mozilla.com/iqrisk.ioc.addr.suricata', 'size' : 1000, 'path' : '/etc/nsm' },
                    'iqrisk.ioc.cat.suricata' : { 'url' : 'https://nsmserver1.private.scl3.mozilla.com/iqrisk.ioc.cat.suricata', 'size' : 1000, 'path' : '/etc/nsm' },
                    'iqrisk.ioc.domain.bro' : { 'url' : 'https://nsmserver1.private.scl3.mozilla.com/iqrisk.ioc.domain.bro', 'size' : 1000, 'path' : '/opt/bro/share/bro/intelzilla' } }

headers = { 'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:35.0) Gecko/20150101 Firefox/35.0',
            'Accept' : 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language' : 'en-US,en;q=0.5',
            'Accept-Encoding' : 'identify',
            'Connection' : 'keep-alive' }

def move_correct(oldname, minsize):

    ret = 2
    newname = oldname[:-4]

    size = os.path.getsize(oldname)
    if size > minsize:
        if os.path.islink(oldname) or os.path.islink(newname) or os.path.isdir(oldname) or os.path.isdir(newname):
            return ret
        else:
            try:
                shutil.move(oldname, newname)
                ret = 0
            except:
                ret = 1

    return ret

def write_list_to_disk(buff, path):

    with open(path, 'w') as f:
        f.write(buff)

def fetch_save(listtype, listdesc):

    request = urllib.request.Request(listdesc['url'], headers=headers)
    with urllib.request.urlopen(request) as data:
        write_list_to_disk(data.read().decode('utf-8'), listdesc['path']+'/'+listtype+'.tmp')

def main():

    for listtype, listdesc in listsandsizes.items():
        for i in range(3):
            fetch_save(listtype, listdesc)
            ret = move_correct(listdesc['path']+'/'+listtype+'.tmp', listdesc['size'])
            if ret == 0:
                break

if __name__ == "__main__":
    main()

