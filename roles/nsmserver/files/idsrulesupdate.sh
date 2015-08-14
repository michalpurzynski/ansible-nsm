#!/bin/bash

NEW_RULES_TMP='/var/www/downloaded.rules.new'
NEW_LOCAL_RULES_TMP='/var/www/local.rules.new'
NOTIFY_EMAIL='mpurzynski@mozilla.com'

NSM_CERT='/etc/ssl/certs/nsmserver1.cert.pem'
NSM_URL='https://nsmserver1.private.scl3.mozilla.com/'

# 0 isn't valid, used to fail in a safe way
SENSOR_OR_SERVER=0
SURIPID=-10

cmd_exists ()
{
    type "$1" &> /dev/null;
}

is_sensor()
{
    if SURIPID=$(pgrep -f suricata); then
        SENSOR_OR_SERVER=1
    elif cmd_exists suricata; then
        SENSOR_OR_SERVER=1
    elif apachepid=$(pgrep -f apache2); then
        SENSOR_OR_SERVER=2
    elif nginxpid=$(pgrep -f nginx); then
        SENSOR_OR_SERVER=2
    fi
}

update_rules()
{
    local rulepath
    local minimumsize
    local actualsize

    rm -f /var/log/nsm/sid_changes.log.old
    cp /var/log/nsm/sid_changes.log /var/log/nsm/sid_changes.log.old
    date >> /var/log/nsm/pulledpork.log

    if [[ "${SENSOR_OR_SERVER}" -eq 2 ]]; then
        pulledpork.pl -P -vv -c /etc/nsm/pulledpork/pulledpork.conf >> /var/log/nsm/pulledpork.log
        rulepath=$(grep ^rule_path /etc/nsm/pulledpork/pulledpork.conf | cut -d '=' -f 2)
        cp -av "${rulepath}" "${NEW_RULES_TMP}"
        chmod 0640 "${NEW_RULES_TMP}"
        chown www-data:www-data "${NEW_RULES_TMP}"
        cp -av "/etc/nsm/rules/local.rules" "${NEW_LOCAL_RULES_TMP}"
        chmod 0640 "${NEW_LOCAL_RULES_TMP}"
        chown www-data:www-data "${NEW_LOCAL_RULES_TMP}"
        mv "${NEW_RULES_TMP}" /var/www/downloaded.rules
        mv "${NEW_LOCAL_RULES_TMP}" /var/www/local.rules
    fi

    if [[ "${SENSOR_OR_SERVER}" -eq 1 && "${SURIPID} -gt 1000" ]]; then
        wget --ca-certificate ${NSM_CERT} ${NSM_URL}/downloaded.rules -O /etc/nsm/rules/downloaded.rules.1 2>&1 > /dev/null
        wget --ca-certificate ${NSM_CERT} ${NSM_URL}/local.rules -O /etc/nsm/rules/local.rules.1 2>&1 > /dev/null
        minimumsize=8000000
        actualsize=$(wc -c /etc/nsm/rules/downloaded.rules.1 2>/dev/null | cut -f 1 -d ' ')
        if [[ actualsize -gt minimumsize ]]; then {
            mv /etc/nsm/rules/downloaded.rules.1 /etc/nsm/rules/downloaded.rules
        } else
            exit 0
        fi
        minimumsize=1200
        actualsize=$(wc -c /etc/nsm/rules/local.rules.1 2>/dev/null | cut -f 1 -d ' ')
        if [[ actualsize -gt minimumsize ]]; then {
            mv /etc/nsm/rules/local.rules.1 /etc/nsm/rules/local.rules
            kill -USR2 "${SURIPID}"
        } else
            exit 0
        fi
    fi

    diff /var/log/nsm/sid_changes.log.old /var/log/nsm/sid_changes.log | mail ${NOTIFY_EMAIL}
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
) 9>/var/run/idsruleupdate.lock

