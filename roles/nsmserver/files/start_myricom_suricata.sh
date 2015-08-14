#!/bin/bash

CPU_NUM=`cat /proc/cpuinfo | grep -E 'model name' | wc -l`

if [[ "${CPU_NUM}" -eq 32 ]]; then
    export SNF_NUM_RINGS=26
elif [[ "${CPU_NUM}" -eq 56 ]]; then
    export SNF_NUM_RINGS=32
else
    exit 1;
fi

export LD_LIBRARY_PATH=/opt/snf/lib
export SNF_DATARING_SIZE=34359738368
export SNF_DESCRING_SIZE=8589934592
export SNF_DEBUG_MASK=0x3
exec /usr/bin/suricata -c /etc/nsm/suricata.yaml -i snf0 --pidfile /var/run/suricata-internal.pid

