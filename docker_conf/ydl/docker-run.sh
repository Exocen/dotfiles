#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

if [ -z ${YDL_MUSIC_PATH+x} ] ; then
    if [ -z "$1" ]; then
        echo "No path supplied"
        exit 1
    else
        VPN_KEY=$1
    fi
fi

if docker images | grep "ydl_img" ; then
    echo "img already created"
else
    cd $(dirname "$(readlink -f "$0")")
    docker build -t ydl_img .
fi

# Reloading vpn
docker restart gluetun &>/dev/null && sleep 1m

#TODO $1 or source arg for data_path
docker run \
    --log-driver=journald --rm \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    -v /docker-data/ydl/:/ydl \
    -v $YDL_MUSIC_PATH:/data \
    --name ydl -d --network=container:gluetun \
    ydl_img:latest && echo "ydl started."
