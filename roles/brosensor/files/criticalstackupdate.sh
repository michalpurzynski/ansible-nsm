#!/bin/bash

NEW_RULES_TMP='/var/www/master-public.bro.dat.tmp'
RULEPATH='/opt/critical-stack/frameworks/intel/master-public.bro.dat'
NOTIFY_EMAIL='<FIXME>'

NSM_CERT='/etc/ssl/certs/nsmserver1.cert.pem'
NSM_URL='https://<FIXME>/'

# 0 isn't valid, used to fail in a safe way
SENSOR_OR_SERVER=0
SURIPID=-10

cmd_exists ()
{
    type "$1" &> /dev/null;
}

is_sensor()
{
    if cmd_exists critical-stack-intel; then
        SENSOR_OR_SERVER=2
    elif apachepid=$(pgrep -f apache2); then
        SENSOR_OR_SERVER=2
    elif nginxpid=$(pgrep -f nginx); then
        SENSOR_OR_SERVER=2
    else
        SENSOR_OR_SERVER=1
    fi
}

update_rules()
{
    local rulepath
    local minimumsize
    local actualsize

    rm -f /var/log/nsm/bro_intel.log.old
    cp /var/log/nsm/bro_intel.log /var/log/nsm/bro_intel.log.old
    rm -f /var/log/nsm/bro_intel.log
    date >> /var/log/nsm/bro_intel.log

    if [[ "${SENSOR_OR_SERVER}" -eq 2 ]]; then
        cp -av "${RULEPATH}" "${NEW_RULES_TMP}"
        chmod 0640 "${NEW_RULES_TMP}"
        chown www-data:www-data "${NEW_RULES_TMP}"
        mv "${NEW_RULES_TMP}" /var/www/master-public.bro.dat
    fi

    if [[ "${SENSOR_OR_SERVER}" -eq 1 ]]; then
        wget --ca-certificate ${NSM_CERT} ${NSM_URL}/master-public.bro.dat -O /opt/bro/share/bro/intelzilla/master-public.bro.dat.1 2>&1 > /dev/null
        minimumsize=1000000
        actualsize=$(wc -c /opt/bro/share/bro/intelzilla/master-public.bro.dat.1 2>/dev/null | cut -f 1 -d ' ')
        if [[ actualsize -gt minimumsize ]]; then {
            mv /opt/bro/share/bro/intelzilla/master-public.bro.dat.1 /opt/bro/share/bro/intelzilla/master-public.bro.dat
        } else
            exit 0
        fi
    fi
}

main()
{
    is_sensor

    if [[ "${SENSOR_OR_SERVER}" -eq 0 ]]; then
        exit 1
    else
        update_rules
    fi
}

(
    flock -n 9 || { echo "This script is currently being run"; exit 1; };
    main
) 9>/var/run/brointelupdate.lock

