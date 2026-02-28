#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z ${FILEBROWSER_PATH+x} ] ; then
        if [ -z "$1" ]; then
            echo "No path supplied"
            exit 1
        else
            FILEBROWSER_PATH=$1
        fi
    fi
fi

cd "$(dirname "$(readlink -f "$0")")" || exit 1

mkdir -p /docker-data/filebrowser/config
mkdir -p /docker-data/filebrowser/database
chown -R 1000:1000 /docker-data/filebrowser

#UserId:GroudId -> 1000:1000 must have folder permission
docker run \
    --name filebrowser --log-driver=journald --log-opt tag="{{.Name}}" --rm -d \
    -e FB_NOAUTH=true \
    -v "/docker-data/filebrowser/config/":/config \
    -v "/docker-data/filebrowser/database/":/database \
    -v "$FILEBROWSER_PATH":/srv \
    -u 1000:1000 \
    -p 80:80 \
    filebrowser/filebrowser
