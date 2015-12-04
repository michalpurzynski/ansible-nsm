#!/bin/bash

main()
{
    [[ ! -f "/nsm/bro/logs/current//nsm/bro/logs/current/conn.log" ]] && sleep 30
    /usr/bin/python /usr/local/sbin/is_file_growing.py /nsm/bro/logs/current/conn.log && exit 0
    /usr/local/sbin/mybroctl.sh restart && exit 0
    /usr/bin/python /usr/local/sbin/pushover.py -a bro -H `hostname` -m "Bro died and cannot be restarted" && exit 0
}

(
    flock -n 9 || { echo "This script is currently being run"; exit 1; };
    main
) 9>/var/run/brodog.lock

