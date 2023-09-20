#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

cd "$(dirname "$(readlink -f "$0")")"
mkdir -p /docker-data/filebrowser/
touch /docker-data/filebrowser/filebrowser.db


filebrowser_path="/docker-data/filebrowser/filebrowser.json"
[ -f "$filebrowser_path" ] || cp default_filebrowser.json $filebrowser_path

docker run \
    --name filebrowser --log-driver=journald --rm -d \
    -e FB_NOAUTH=noauth \
    -v /docker-data/filebrowser/filebrowser.db:/database/filebrowser.db \
    -v $filebrowser_path:/.filebrowser.json \
    -v /SSD_2T:/srv \
    -u $(id -u):$(id -g) \
    -p 80:80 \
    filebrowser/filebrowser
