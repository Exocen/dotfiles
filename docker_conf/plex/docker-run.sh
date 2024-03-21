#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

docker run -d --rm --log-driver=journald \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --network=host \
    -e PUID=1000 \
    -e PGID=1000 \
    -p 32400:32400/tcp \
    -v /docker-data/plex:/data \
    --name=plex \
    linuxserver/plex:latest && echo "Plex started."
