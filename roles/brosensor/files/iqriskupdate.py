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

wantedcats = { 'CnC':100, 'Drop':100, 'DriveBySrc':100, 'Compromised':100, 'FakeAV':100, 'Blackhole':100, 'P2PCnC':100, 'Mobile_CnC':100, 'Abused TLD':100, 'SelfSignedSSL':100, 'Bitcoin_Related':100 }

headers = { 'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:35.0) Gecko/20150101 Firefox/35.0',
            'Accept' : 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language' : 'en-US,en;q=0.5',
            'Accept-Encoding' : 'identify',
            'Connection' : 'keep-alive' }

def fetch_list(url):

    request = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(request) as data:
        return data.read().decode('utf-8')

def filter_list(ioc_list):

    url = 'https://rules.emergingthreatspro.com/<FIXME>/reputation/categories.txt'
    filename = '/var/www/iqrisk.ioc.cat.suricata'

    filtered_ioc_list = {}
    categories_to_num = {}

    request = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(request) as data:
        with open(filename, 'w') as f:
            #f.write(data.read().decode('ascii', 'ignore'))
            for line in data.readlines():
                f.write(line.decode('ascii','ignore'))
                (catnum, catname, catdesc) = line.decode('ascii','ignore').split(',')
                categories_to_num[catname] = catnum

    for indicator, data in ioc_list.items():
        for category, score in data.items():
            if category in wantedcats:
                if int(score) > int(wantedcats[category]):
                    filtered_ioc_list[indicator] = { 'desc': category + '_' + score, 'score': score, 'catnum': categories_to_num[category] }

    f.close()

    return filtered_ioc_list

def write_bro_intel(data, listtype):

    if listtype == 'addr':
        filename = '/var/www/iqrisk.ioc.addr.bro'
        ioctype = 'Intel::ADDR'
    elif listtype == 'domain':
        filename = '/var/www/iqrisk.ioc.domain.bro'
        ioctype = 'Intel::DOMAIN'

    with open(filename, 'w') as f:
        print('#fields\tindicator\tindicator_type\tmeta.source\tmeta.desc\tmeta.url', file=f)
        for indicator, details in data.items():
            print('\t'.join([indicator, ioctype, details['desc'], 'IQRisk', 'http://www.emergingthreats.com']), file=f)

    f.close()

def write_suricata_intel(data):

    filename = '/var/www/iqrisk.ioc.addr.suricata'

    with open(filename, 'w') as f:
        for indicator, details in data.items():
            print(','.join([indicator, details['catnum'], details['score']]), file=f)

    f.close()

def main():

    urls = { 'domain': 'https://rules.emergingthreatspro.com/<FIXME>/reputation/domainrepdata.json',
            'addr': 'https://rules.emergingthreatspro.com/<FIXME>/reputation/iprepdata.json' }

    for listtype, url in urls.items():
        data = fetch_list(url)
        json_data = json.loads(data)
        filtered_ioc_list = filter_list(json_data)
        write_bro_intel(filtered_ioc_list, listtype)

    write_suricata_intel(filtered_ioc_list)

if __name__ == "__main__":
    main()

