#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

docker run -d --rm --log-driver=journald \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    -p 32400:32400/tcp \
    -u 1000:1000 \
    -v /docker-data/plex:/data \
    --name=plex \
     plexinc/pms-docker:latest && echo "Plex started."
