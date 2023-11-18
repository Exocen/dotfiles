#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z ${MAIL_DOMAIN+x} ] ; then
        if [ -z "$1" ]; then
            echo "No domain supplied"
            exit 1
        else
            MAIL_DOMAIN=$1
        fi
    fi
fi

# imap tls implicit 992
# smtp tls implicit 464

docker run -d --rm --log-driver=journald \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    -v /docker-data/dms/mail-data:/var/mail -v /docker-data/dms/mail-state:/var/mail-state \
    -v /docker-data/dms/mail-logs:/var/log/mail -v /docker-data/dms/config:/tmp/docker-mailserver \
    -v /docker-data/letsencrypt:/etc/letsencrypt \
    -p 25:25 -p 464:465 -p 992:993 \
    -e ENABLE_FAIL2BAN=1 -e SSL_TYPE=letsencrypt -e PERMIT_DOCKER=network \
    -e ONE_DIR=1 -e ENABLE_POSTGREY=0 -e ENABLE_CLAMAV=0 -e ENABLE_SPAMASSASSIN=0 -e SPOOF_PROTECTION=0 \
    --cap-add=NET_ADMIN \
    --name mail_server --hostname=$MAIL_DOMAIN \
    mailserver/docker-mailserver && echo "mail_server started."
