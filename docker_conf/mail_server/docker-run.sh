#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z ${MAIL_DOMAIN+x} ] ; then
        if [ -z "$1" ]; then
            echo "No domain supplied"
            exit 1
        else
            MAIL_DOMAIN="mail.$1"
            echo "Using $MAIL_DOMAIN"
        fi
    fi
    if [ -z ${POSTMASTER_ADDRESS+x} ] ; then
        if [ -z "$1" ]; then
            POSTMASTER_ADDRESS="postmaster@example.com"
        fi
    fi
fi

cd $(dirname "$(readlink -f "$0")")

if ./disable-ipv6.sh ; then
docker run -d --rm --log-driver=journald --log-opt tag="{{.Name}}" \
    -v /etc/localtime:/etc/localtime:ro \
    -v /docker-data/dms/mail-data:/var/mail -v /docker-data/dms/mail-state:/var/mail-state \
    -v /docker-data/dms/mail-logs:/var/log/mail -v /docker-data/dms/config:/tmp/docker-mailserver \
    -v /docker-data/letsencrypt:/etc/letsencrypt \
    -p 25:25 -p 465:465 -p 993:993 -p 4190:4190\
    -e ENABLE_FAIL2BAN=1 -e SSL_TYPE=letsencrypt -e PERMIT_DOCKER=network \
    -e ONE_DIR=1 -e ENABLE_CLAMAV=0 -e ENABLE_SPAMASSASSIN=1 -e SPOOF_PROTECTION=1 -e ENABLE_MANAGESIEVE=1 \
    -e POSTMASTER_ADDRESS="$POSTMASTER_ADDRESS" -e ENABLE_UPDATE_CHECK=1 -e PFLOGSUMM_TRIGGER="logrotate" -e LOGWATCH_INTERVAL="daily" \
    -e ENABLE_OPENDKIM=1 -e ENABLE_OPENDMARC=1 -e ENABLE_POLICYD_SPF=1 \
    --cap-add=NET_ADMIN \
    --name mail_server --hostname="$MAIL_DOMAIN" \
    mailserver/docker-mailserver && echo "mail_server started."
else
    echo ipv6 NOT disabled, stopping mail_server
fi
