#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

docker images | grep "ydl_img" || docker build -t ydl_img .

docker run \
    --log-driver=journald --rm \
    -v /docker-data/ydl/:/ydl \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --name ydl -d --network=container:gluetun \
    ydl_img:latest && echo "ydl started."
