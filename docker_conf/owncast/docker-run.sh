#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

DOCKER_PATH="/docker-data/owncast"

cd "$(dirname "$(readlink -f "$0")")" || exit 1
mkdir -p $DOCKER_PATH

docker run -d --rm --log-driver=journald --log-opt tag="{{.Name}}" \
    -v /etc/localtime:/etc/localtime:ro \
    -v "$DOCKER_PATH":/app/data \
    --net user_network --ip 10.0.0.84 \
    -p 1935:1935 \
    --name=owncast \
    owncast/owncast:latest && echo "owncast started."
