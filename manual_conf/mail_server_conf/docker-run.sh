#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z "$1" ]; then
        echo "No domain supplied"
        exit 1
    fi
fi

docker stop mail_server
docker rm mail_server
docker build --build-arg DOMAIN=$1 -t mail_server_img . && \
    \
    docker run -v /etc/letsencrypt/:/etc/letsencrypt/ -v /post_base:/post_base -v /var/mail/vhosts:/var/mail/vhosts -v /var/log/mail_server:/var/log -p 25:25 -p 587:587 -p 465:465 -p 143:143 -p 993:993 --name mail_server -d --restart unless-stopped mail_server_img:latest

