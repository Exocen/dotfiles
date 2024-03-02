#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z ${SYNCTHING_PATH+x} ] ; then
        if [ -z "$1" ]; then
            SYNCTHING_PATH="/docker-data/syncthing/root/"
        fi
    fi
fi

#PGUID 1000 PGID 1000 -> must have folder permission
docker run -d --rm --log-driver=journald \
    --name=syncthing \
    -e PUID=1000 \
    -e PGID=1000 \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    -p 8384:8384 \
    -p 22000:22000/tcp \
    -p 22000:22000/udp \
    -p 21027:21027/udp \
    -v /docker-data/syncthing/config:/config \
    -v $SYNCTHING_PATH:/data1 \
    lscr.io/linuxserver/syncthing:latest && echo "syncthing started."
