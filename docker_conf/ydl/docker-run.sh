#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

docker stop ydl
docker rm ydl
docker build -t ydl_img . && \
    \
    docker run --log-driver=journald -v /docker-data/ydl/:/ydl --name ydl -d --network=container:gluetun --restart unless-stopped ydl_img:latest
