#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z ${SYNCTHING_PATH+x} ]; then
        if [ -z "$1" ]; then
            SYNCTHING_PATH="/docker-data/syncthing/root/"
        else
            SYNCTHING_PATH=$1
        fi
    fi
fi

if docker images | grep "syncthing"; then
    echo "img already created"
else
    cd "$(dirname "$(readlink -f "$0")")" || exit 1
    docker build -t syncthing .
fi

mkdir -p /docker-data/syncthing/config
chown 1000:1000 -R /docker-data/syncthing/config
mkdir -p /docker-data-nobackup/syncthing/data
chown 1000:1000 -R /docker-data-nobackup/syncthing/data

#PGUID 1000 PGID 1000 -> must have folder permission
docker run -d --rm --log-driver=journald --log-opt tag="{{.Name}}" \
    --name=syncthing \
    -e PUID=1000 \
    -e PGID=1000 \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --network=container:gluetun \
    -v /docker-data/syncthing/config:/var/syncthing/config \
    -v /docker-data-nobackup/syncthing/data:/var/syncthing/data \
    -v "$SYNCTHING_PATH":/data1 \
    syncthing:latest && echo "syncthing started."
