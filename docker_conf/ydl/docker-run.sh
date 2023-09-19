#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

if docker images | grep "ydl_img" ; then
    echo "img already created"
else
    cd $(dirname "$(readlink -f "$0")")
    docker build -t ydl_img .
fi

docker run \
    --log-driver=journald --rm \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    -v /docker-data/ydl/:/ydl \
    -v /Music/:/Music
    --name ydl -d --network=container:gluetun \
        ydl_img:latest && echo "ydl started."
