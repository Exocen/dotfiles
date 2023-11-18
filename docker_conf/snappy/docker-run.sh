#!/bin/bash

if [ `id -u` -ne 0 ]; then
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

docker run -d --rm --log-driver=journald \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    -v /docker-data/snappymail:/snappymail/data
    --net user_network --ip 10.0.0.82 \
    --name=snappymail \
    kouinkouin/snappymail && echo "Snappymail started."
