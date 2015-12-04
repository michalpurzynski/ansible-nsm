#!/bin/bash

tmp=''
tmp=`df -P / | grep sda1 | tr -s ' ' '\t'`
# / used in KB
t[1]=`echo "$tmp" | cut -f 3`
# / free in KB
t[2]=`echo "$tmp" | cut -f 4`

# ELSA disabled?
elsa_disabled="yes"
if [ "$elsa_disabled" = "yes" ] ; then
	t[3]=0
	t[4]=0
	t[5]=0
        t[6]=0
        t[7]=0;
else
	tmp=''
	tmp=`du -s /nsm/elsa/data/* | cut -f 1`
	# Elsa log data disk space used (KB)
	t[3]=`echo "$tmp" | head -n 1`
	# Sphinx indexes disk space used (KB)
	t[4]=`echo "$tmp" | tail -n 1`

	tmp=''
	# First index size (KB)
	t[5]=`du -s /nsm/elsa/data/sphinx/perm_1.{spi,spd} | awk '{ size+=$1 } END { print size }'`;

	# details.elsa.buffersqueued_int
	t[6]=`ls -alt /nsm/elsa/data/elsa/tmp/buffers/* | grep -v host_stats | wc -l`

	# details.elsa.dayskept_int
	t[7]=`mysql -B -uroot -Dsyslog -e "SELECT DATEDIFF(MAX(start),MIN(end)) FROM syslog.v_indexes" | egrep '[[:digit:]]+'`
fi

tmp=''
tmp=`free | grep cache | grep '\+' | tr -s ' ' '\t'`
# Memory used in (KB)
t[8]=`echo "$tmp" | cut -f 3`
# Memory free (KB)
t[9]=`echo "$tmp" | cut -f 4`

tmp=''
tmp=`cat /proc/loadavg`
# Load average
t[10]=`echo "$tmp" | cut -d ' ' -f 1`
t[11]=`echo "$tmp" | cut -d ' ' -f 2`
t[12]=`echo "$tmp" | cut -d ' ' -f 3`

tmp=''
tmp=`ps aux`
# Total number of processes
t[13]=`echo "$tmp" | wc -l`
# Number of bro processes
t[14]=`echo "$tmp" | grep -v grep | grep bro | wc -l`

if test -f "/opt/snf/bin/myri_counters"; then
        tmp=''
        tmp=`/opt/snf/bin/myri_counters | tr -s ' ' '\t'`
        # Net recv KBytes
        t[15]=`echo "$tmp" | grep recv | grep KBytes | cut -f 5`
        # Ethernet recv overrun
        t[16]=`echo "$tmp" | grep recv | grep overrun | cut -f 5`
        # SNF recv pkts
        t[17]=`echo "$tmp" | grep recv | grep pkts | cut -f 5`
        # SNF drop ring full
        t[18]=`echo "$tmp" | grep drop | grep full | cut -f 6`
        # Net bad PHY/CRC32 drop
        t[19]=`echo "$tmp" | grep drop | grep CRC32 | cut -f 6`
        # Net overflow drop
        t[20]=`echo "$tmp" | grep drop | grep overflow | cut -f 5`
        # Ethernet Multicast filter drop
        t[21]=`echo "$tmp" | grep drop | grep Multicast | cut -f 6`
        # Ethernet Unicast filter drop
        t[22]=`echo "$tmp" | grep drop | grep Unicast | cut -f 6`
        # Interrupts
        t[23]=`echo "$tmp" | grep Interrupts | cut -f 3`;
else
	t[16]=0 
	t[17]=0
	t[18]=0
	t[19]=0
	t[20]=0
	t[21]=0
	t[22]=0
	t[23]=0
	# Net recv KBytes
    if hostname -s | grep -E 'sfo1|mtv2'; then
        interface='eth5'
    else
        interface='eth2'
    fi
    t[15]=`echo $(($(/sbin/ifconfig "${interface}" | grep 'RX bytes' | cut -d ':' -f 2 | cut -d ' ' -f 1) / 1024))`
fi

if [[ "${t[17]}" -gt 0 ]]; then
    t[24]=$(($((${t[16]}+${t[18]}+${t[19]}+${t[20]}+${t[21]}+${t[22]}))/${t[17]}))
else
    t[24]=0
fi

tmp=''

for i in {1..24}; do
	echo -n ${t[$i]};
	echo -ne '\t';
done;
echo ""

