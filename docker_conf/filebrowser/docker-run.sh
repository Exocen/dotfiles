#!/bin/bash

if [ `id -u` -ne 0 ]; then
     echo "Must be run as root"
     exit 1
 fi

docker run \
    --name filebrowser --log-driver=journald --rm -d \
    -v /SSD_2T:/srv \
    -v /docker-data/filebrowser/:/root/ \
    -u $(id -u):$(id -g) \
    -p 8080:8080 \
    filebrowser/filebrowser -c /root/.filebrowser.json -d /root/filebrowser.db -r /root/data
