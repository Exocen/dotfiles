#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

DOCKER_PATH="/docker-data/fmd-server/db"

cd "$(dirname "$(readlink -f "$0")")" || exit 1
mkdir -p $DOCKER_PATH
chown 1000:1000 $DOCKER_PATH

docker run -d --rm --log-driver=journald --log-opt tag="{{.Name}}" \
    -v /etc/localtime:/etc/localtime:ro \
    -v "$DOCKER_PATH":/var/lib/fmd-server/db/ \
    --net user_network --ip 10.0.0.83 \
    --name=fmd_server \
    registry.gitlab.com/fmd-foss/fmd-server && echo "fmd_server started."
