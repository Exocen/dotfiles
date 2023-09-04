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
    docker run -v /docker-data/letsencrypt/:/etc/letsencrypt/ -v /docker-data/mail_server-data:/post_base --log-driver=journald -p 25:25 -p 587:587 -p 465:465 -p 143:143 -p 993:993 --name mail_server -d --restart unless-stopped mail_server_img:latest

