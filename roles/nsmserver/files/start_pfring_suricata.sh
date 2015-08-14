#!/bin/bash
exec suricata -c /etc/nsm/suricata.yaml -F /etc/nsm/suri-bpf.conf --pfring --pidfile /var/run/suricata-internal.pid

