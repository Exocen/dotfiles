#!/bin/bash

if [ `id -u` -ne 0 ]; then
     echo "Must be run as root"
     exit 1
 fi

docker run \
    --name filebrowser --log-driver=journald --rm -d \
    -v /SSD_2T:/srv \
    -v /docker-data/filebrowser/filebrowser.db:/database.db \
    -v /docker-data/filebrowser/.filebrowser.json:/.filebrowser.json \
    -u $(id -u):$(id -g) \
    -p 8080:8080 \
    filebrowser/filebrowser
