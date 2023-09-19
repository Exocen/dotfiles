#!/bin/bash

if [ `id -u` -ne 0 ]; then
     echo "Must be run as root"
     exit 1
 fi

docker run -d \
    --name filebrowser --log-driver=journald --rm \
    --user $(id -u):$(id -g) \
    -p 8080:8080 \
    -v /docker-data/filebrowser/data:/data \
    -v /docker-data/filebrowser/config/:/config \
    -e FB_BASEURL=/data-path \
    hurlenko/filebrowser
