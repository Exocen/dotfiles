#!/bin/bash

if [ `id -u` -ne 0 ]; then
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

cd "$(dirname "$(readlink -f "$0")")"
mkdir -p /docker-data/filebrowser/
touch /docker-data/filebrowser/filebrowser.db


filebrowser_settings_path="/docker-data/filebrowser/filebrowser.json"
[ -f "$filebrowser_settings_path" ] || cp default_filebrowser.json $filebrowser_settings_path

docker run \
    --name filebrowser --log-driver=journald --rm -d \
    -e FB_NOAUTH=noauth \
    -v /docker-data/filebrowser/filebrowser.db:/database/filebrowser.db \
    -v $filebrowser_settings_path:/.filebrowser.json \
    -v $FILEBROWSER_PATH:/srv \
    -u $(id -u):$(id -g) \
    -p 80:80 \
    filebrowser/filebrowser
