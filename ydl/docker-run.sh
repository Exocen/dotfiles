#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

if [ -z ${YDL_MUSIC_PATH+x} ] ; then
    if [ -z "$1" ]; then
        echo "No path supplied"
        exit 1
    else
        YDL_MUSIC_PATH=$1
    fi
fi

if docker images | grep "ydl_img" ; then
    echo "img already created"
else
    cd "$(dirname "$(readlink -f "$0")")" || exit 1
    docker build -t ydl_img .
fi

docker run \
    --log-driver=journald --log-opt tag="{{.Name}}" --rm \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    -v /docker-data/ydl/:/ydl \
    -v "$YDL_MUSIC_PATH":/data \
    --name ydl -d --network=container:gluetun \
    ydl_img:latest && echo "ydl started."
