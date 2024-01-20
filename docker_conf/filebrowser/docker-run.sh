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

DOCKER_PATH="/docker-data/filebrowser/"
FILEBROWSER_DB_PATH="$DOCKER_PATH/filebrowser.db"
FILEBROWSER_SETTINGS_PATH="$DOCKER_PATH/filebrowser.json"

cd "$(dirname "$(readlink -f "$0")")"
mkdir -p $DOCKER_PATH

[ -f "$FILEBROWSER_SETTINGS_PATH" ] || echo -en '{\n    "port": 80,\n    "baseURL": "",\n    "address": "",\n    "log": "stdout",\n    "database": "/database.db",\n    "root": "/srv"\n}' > $FILEBROWSER_SETTINGS_PATH

[ -f "$FILEBROWSER_DB_PATH" ] || touch $FILEBROWSER_DB_PATH

docker run \
    --name filebrowser --log-driver=journald --rm -d \
    -e FB_NOAUTH=noauth \
    -v $FILEBROWSER_DB_PATH:/database.db \
    -v $FILEBROWSER_SETTINGS_PATH:/.filebrowser.json \
    -v $FILEBROWSER_PATH:/srv \
    -u 1000:1000 \
    -p 80:80 \
    filebrowser/filebrowser
