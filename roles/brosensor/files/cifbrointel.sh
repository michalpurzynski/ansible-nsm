#!/bin/bash

(cd /opt/bro/share/bro/intelzilla && rm -fv cif.*.intel && for i in cif.dns.domain.botnet.65.intel cif.dns.domain.malware.85.intel cif.http.url.botnet.85.intel cif.http.url.malware.85.intel cif.http.url.phishing.85.intel cif.ip.infrastructure.botnet.65.intel cif.ip.infrastructure.malware.85.intel; do wget https://cifclient1.private.scl3.mozilla.com/cif/$i; done;)

