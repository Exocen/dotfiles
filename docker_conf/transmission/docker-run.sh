#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

# TODO need to arg or source paths
docker run -d --rm --log-driver=journald \
    --name=transmission \
    -e PUID=1000 \
    -e PGID=1000 \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --network=container:gluetun \
    -v /docker-data/transmission/config/:/config \
    -v /docker-data/transmission/dl/:/downloads \
    lscr.io/linuxserver/transmission:latest
