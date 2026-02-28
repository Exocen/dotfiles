#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root."
    exit 1
else
    if [ -z ${VW_ADMIN_PASS_ENABLED+x} ] ; then
        if [ -z "$1" ]; then
            echo "Usage: script y/n (admin pass)."
            exit 1
        else
            case $1 in
                [Yy]* ) VW_ADMIN_PASS_ENABLED=1;;
                [Nn]* ) VW_ADMIN_PASS_ENABLED=0;;
                * ) echo "Usage: script y/n (admin pass)."; exit 1;;
            esac
        fi
    fi
fi

docker network create --subnet 10.0.0.0/8 user_network 2>/dev/null

if [ "$VW_ADMIN_PASS_ENABLED" -eq 1 ]; then
    PASS=$(openssl rand -base64 48)
    docker run  \
        -d --name vaultwarden --rm \
        -v /docker-data/vaultwarden/:/data/ \
        -v /etc/localtime:/etc/localtime:ro \
        --log-driver=journald --log-opt tag="{{.Name}}" -e ADMIN_TOKEN="$PASS" \
        --net user_network --ip 10.0.0.80 vaultwarden/server:latest-alpine && echo "vaultwarden started."

    echo -e "admin pass:\n$PASS\nUse it on https://VW-DOMAIN/admin"
else
    [[ -f /docker-data/vaultwarden-data/config.json ]] &&  sed -i '/admin_token/d' /docker-data/vaultwarden-data/config.json
    docker run  \
        -d --name vaultwarden --rm \
        -v /docker-data/vaultwarden/:/data/ \
        -v /etc/localtime:/etc/localtime:ro \
        --log-driver=journald --log-opt tag="{{.Name}}" \
        --net user_network --ip 10.0.0.80 vaultwarden/server:latest-alpine && echo "vaultwarden started."
fi
