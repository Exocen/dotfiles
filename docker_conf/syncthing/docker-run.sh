#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z ${SYNCTHING_PATH+x} ] ; then
        if [ -z "$1" ]; then
            SYNCTHING_PATH="/docker-data/syncthing/root/"
        else
            SYNCTHING_PATH=$1
        fi
    fi
fi

#PGUID 1000 PGID 1000 -> must have folder permission
docker run -d --rm --log-driver=journald \
    --name=syncthing \
    -e PUID=1000 \
    -e PGID=1000 \
    -e STDATADIR=/var/syncthing/data/db \
    -e STCONFDIR=/var/syncthing/config \
    -e STHOMEDIR= \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --network=container:gluetun \
    -v /docker-data-nobackup/syncthing/data:/var/syncthing/data \
    -v /docker-data/syncthing/config:/var/syncthing/config \
    -v $SYNCTHING_PATH:/data1 \
    syncthing/syncthing:latest && echo "syncthing started."
