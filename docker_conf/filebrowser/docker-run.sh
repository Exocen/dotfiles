#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

mkdir -p /docker-data/filebrowser/
touch /docker-data/filebrowser/filebrowser.db
docker run \
    --name filebrowser --log-driver=journald --rm -d \
    -e FB_NOAUTH=noauth
    -v /SSD_2T:/srv \
    -u $(id -u):$(id -g) \
    -p 80:80 \
    filebrowser/filebrowser
