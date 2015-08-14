#! /usr/bin/env python

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# The Initial Developer of the Original Code is
# Mozilla Corporation
# Portions created by the Initial Developer are Copyright (C) 2014
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
# Michal Purzynski mpurzynski@mozilla.com

import sys, getopt
import urllib2, urllib

def usage():
    print 'pushover.py -a <application> -m <message> [-H <hostname>]'

def sendpush(app, msg, host):
    headers = { 'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:35.0) Gecko/20100101 Firefox/35.0',
            'Accept' : 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language' : 'en-US,en;q=0.5',
            'Accept-Encoding' : 'identify',
            'Connection' : 'keep-alive',
            'Content-type' : 'application/x-www-form-urlencoded' }

    title = app + " on " + host

    post_args = { 'token' : '<FIXME>',
                'user' : '<FIXME>',
                'title' : title,
                'message' : msg }

    post_data = urllib.urlencode(post_args)

    req = urllib2.Request('https://api.pushover.net/1/messages.json', post_data, headers)
    f = urllib2.urlopen(req)

def main(argv):

    app = ''
    host = ''

    try:
        opts, args = getopt.getopt(argv,"ha:m:H:")
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            usage()
            sys.exit()
        elif opt in ("-a"):
            app = arg
        elif opt in ("-m"):
            msg = arg
        elif opt in ("-H"):
            host = arg

    sendpush(app, msg, host)

if __name__ == "__main__":
   main(sys.argv[1:])
