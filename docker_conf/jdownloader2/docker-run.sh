#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z ${JDOWNLOADER_DL_PATH+x} ] ; then
        if [ -z "$1" ]; then
            JDOWNLOADER_DL_PATH="/docker-data/jdownloader2/dl/"
        fi
    fi
fi

cd "$(dirname "$(readlink -f "$0")")" || exit 1

if docker images | grep "jdownloader2_img" ; then
    echo "img already created"
else
    docker build -t jdownloader2_img .
fi

#add this cmd to reconnect batch option with /bin/sh interpreter
# /root/reco.sh
#PGUID 1000 PGID 1000 -> must have folder permission
docker run -d --rm --log-driver=journald --log-opt tag="{{.Name}}" \
    --name=jdownloader2 \
    -e PUID=1000 \
    -e PGID=1000 \
    -e KEEP_APP_RUNNING=1 \
    -e DARK_MODE=1 \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --network=container:gluetun \
    -v /docker-data-nobackup/jdownloader2/config/:/config \
    -v "$JDOWNLOADER_DL_PATH":/output \
    jdownloader2_img:latest && echo "Jdownloader2 started."
