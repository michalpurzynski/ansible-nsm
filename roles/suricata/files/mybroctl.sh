#!/bin/bash

BROCTL='/opt/bro/bin/broctl'

broctl_restart ()
{
        #broctl_check || exit 1
        "${BROCTL}" install 2>&1 > /dev/null || exit 1
        ("${BROCTL}" stop 2>&1 > /dev/null) &
        sleep 30
        if ps aux | grep bro | egrep -v 'grep|trace-summary|summarize-connections|archive-log|post-terminate|mybroctl'; then
                killall -9 bro
                sleep 10
                killall -9 bro
        fi
        "${BROCTL}" start &
        exit 0
}

broctl_check ()
{
        rm -f /var/run/broctl_check.ok 2>&1 > /dev/null
        short_host=`hostname -s`
        broeth=`ps aux | grep -E 'local-worker.bro' | grep -E -o 'eth[[:digit:]]+' | head -1`
        ("${BROCTL}" check "${short_host}"-"${broeth}"-1 && echo $? > /var/run/broctl_check.ok) &
        sleep 30
        ppid=`pgrep -f 'broctl check'`
        if [[ ! -e "/var/run/broctl_check.ok" || "${ppid}" -gt 100 ]]; then
        # risky - broctl might have ended in the meantime and ppid could have been assigned to a new process
                kill -9 "${ppid}" 2>&1 > /dev/null
                sleep 3
                return 1
        else
                return 0
        fi
}

main()
{
    case "$1" in
        restart) shift;     broctl_restart "$@" ;;
        check) shift;       broctl_check "$@" ;;
    esac
}

(
    flock -n 9 || { echo "This script is currently being run"; exit 1; };
    main $1
) 9>/var/run/mybroctl.lock

