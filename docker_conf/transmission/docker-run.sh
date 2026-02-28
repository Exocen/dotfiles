#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z ${TRANSMISSION_DL_PATH+x} ] ; then
        if [ -z "$1" ]; then
            TRANSMISSION_DL_PATH="/docker-data/transmission/dl/"
        fi
    fi
fi

#PGUID 1000 PGID 1000 -> must have folder permission
docker run -d --rm --log-driver=journald --log-opt tag="{{.Name}}" \
    --name=transmission \
    -e PUID=1000 \
    -e PGID=1000 \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --network=container:gluetun \
    -v /docker-data/transmission/config/:/config \
    -v "$TRANSMISSION_DL_PATH":/downloads \
    --health-cmd="curl --silent --fail 1.1.1.1 1>/dev/null && curl --silent --fail localhost:9091 1>/dev/null || exit 1" \
    --health-start-period=5m \
    lscr.io/linuxserver/transmission:latest && echo "transmission started."
