#!/bin/bash

docker run -d \
    --name filebrowser \
    --user $(id -u):$(id -g) \
    -p 8080:8080 \
    -v /data:/data \
    -v /docker-data/filebrowser/:/config \
    -e FB_BASEURL=/filebrowser \
    hurlenko/filebrowser
