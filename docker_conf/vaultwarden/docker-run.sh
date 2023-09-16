#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root."
    exit 1
else
    if [ -z "$1" ]; then
        echo "Usage: script y/n (admin pass)."
        exit 1
    elif [ "$1" == "default" ]; then
        PASS_ENABLED=0
    else
        case $1 in
            [Yy]* ) PASS_ENABLED=1;;
            [Nn]* ) PASS_ENABLED=0;;
            * ) echo "Usage: script y/n (admin pass)."; exit 1;;
        esac

    fi
fi

docker network create --subnet 10.0.0.0/8 user_network 2>/dev/null

if [ $PASS_ENABLED -eq 1 ]; then
    PASS=`openssl rand -base64 48`
    docker run  \
        -d --name vaultwarden --rm \
        -v /docker-data/vaultwarden-data/:/data/ \
        -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
        --log-driver=journald -e ADMIN_TOKEN=$PASS \
        --net user_network --ip 10.0.0.80 vaultwarden/server:latest && echo "vaultwarden started."
            echo -e "admin pass:\n$PASS\nUse it on https://VW-DOMAIN/admin"
        else
            [[ -f /docker-data/vaultwarden-data/config.json ]] &&  sed -i '/admin_token/d' /docker-data/vaultwarden-data/config.json
            docker run  \
                -d --name vaultwarden --rm \
                -v /docker-data/vaultwarden-data/:/data/ \
                -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
                --log-driver=journald \
                --net user_network --ip 10.0.0.80 vaultwarden/server:latest && echo "vaultwarden started."
fi
