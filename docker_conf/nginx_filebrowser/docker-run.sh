#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z ${NGINX_FILEBROWSER_PATH+x} ] ; then
        if [ -z "$1" ]; then
            echo "No path supplied"
            exit 1
        else
            NGINX_FILEBROWSER_PATH=$1
        fi
    fi
fi

cd "$(dirname "$(readlink -f "$0")")" || exit 1

docker run \
    --name nginx_filebrowser --log-driver=journald --log-opt tag="{{.Name}}" --rm -d \
    -v "$NGINX_FILEBROWSER_PATH":/usr/share/nginx/html/:ro \
    -v `pwd -P`/nginx-conf:/etc/nginx/nginx.conf:ro \
    -p 6080:80 \
    nginx:mainline-alpine
