#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi
if [ -z ${DOMAIN+x} ] ; then
    if [ -z "$1" ]; then
        echo "No domain supplied"
        exit 1
    else
        DOMAIN=$1
    fi
fi

docker run -d --rm --log-driver=journald --log-opt tag="{{.Name}}" \
    -e ROUNDCUBEMAIL_DEFAULT_HOST=ssl://"$DOMAIN" -e ROUNDCUBEMAIL_SMTP_SERVER=ssl://"$DOMAIN" \
    -e ROUNDCUBEMAIL_SMTP_PORT=464 -e ROUNDCUBEMAIL_DEFAULT_PORT=992 \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --net user_network --ip 10.0.0.82 \
    --name=roundcube \
    roundcube/roundcubemail:latest-fpm-alpine && echo "Roundcube started."
