#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

if docker ps | grep "mail_server" &>/dev/null; then
    docker exec -ti mail_server setup "$@"
else
    echo "mail_server must run"
fi
