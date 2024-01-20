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

FILEBROWSER_SETTINGS_PATH="/docker-data/filebrowser/filebrowser.json"
FILEBROWSER_DB_PATH="/docker-data/filebrowser/filebrowser.db"

if [ ! -f "$FILEBROWSER_DB_PATH" ] ; then
    touch $FILEBROWSER_DB_PATH
    chown 1000:1000 $FILEBROWSER_DB_PATH
fi

docker run \
    --name filebrowser --log-driver=journald --rm -d \
    -e FB_NOAUTH=noauth \
    -v $FILEBROWSER_DB_PATH:/database.db \
    -v $FILEBROWSER_SETTINGS_PATH:/.filebrowser.json \
    -v $FILEBROWSER_PATH:/srv \
    -u 1000:1000 \
    -p 80:80 \
    filebrowser/filebrowser
