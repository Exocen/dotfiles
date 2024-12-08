#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

docker run -d --rm --log-driver=journald --log-opt tag="{{.Name}}" \
    --name=firefox \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --network=container:gluetun \
    -e KEEP_APP_RUNNING=1 \
    -e DARK_MODE=1 \
    -e WEB_LISTENING_PORT=6800 \
    -e VNC_LISTENING_PORT=6900 \
    -v /docker-data-nobackup/firefox/:/config:rw \
    jlesage/firefox && echo "Firefox started."
