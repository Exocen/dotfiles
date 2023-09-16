#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

if docker images | grep "ydl_img" ; then
     echo "img already created"
 else
     cd $(dirname "$(readlink -f "$0")")
     docker build --build-arg DOMAIN=$DOMAIN -t ydl_img .
 fi
nginx_certbot_img

docker run \
    --log-driver=journald --rm \
    -v /docker-data/ydl/:/ydl \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --name ydl -d --network=container:gluetun \
    ydl_img:latest && echo "ydl started."
