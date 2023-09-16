#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z "$1" ]; then
        echo "No domain supplied"
        exit 1
    elif [ "$1" == "default" ]; then
        DOMAIN=`hostnamectl --static`
    else
        DOMAIN=$1
    fi
fi

if docker images | grep "mail_server_img" ; then
    echo "img already created"
else
    cd $(dirname "$(readlink -f "$0")")
    docker build --build-arg $DOMAIN -t mail_server_img .
fi

docker run \
    -v /docker-data/letsencrypt/:/etc/letsencrypt/ -v /docker-data/mail_server-data:/post_base \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --log-driver=journald --rm \
    -p 25:25 -p 587:587 -p 465:465 -p 143:143 -p 993:993 \
    --name mail_server -d mail_server_img:latest && echo "mail_server started."

