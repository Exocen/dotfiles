#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z ${JDOWNLOADER_DL_PATH+x} ] ; then
        if [ -z "$1" ]; then
            JDOWNLOADER_DL_PATH="/docker-data/jdownloader/dl/"
        fi
    fi
fi

#PGUID 1000 PGID 1000 -> must have folder permission
docker run -d --rm --log-driver=journald \
    --name=jdownloader \
    -e PUID=1000 \
    -e PGID=1000 \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --network=container:gluetun \
    -v /docker-data/jdownloader/config/:/config \
    -v $JDOWNLOADER_DL_PATH:/output \
    jlesage/jdownloader-2 && echo "Jdownloader started."
