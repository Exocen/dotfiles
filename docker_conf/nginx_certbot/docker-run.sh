#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z ${DOMAIN+x} ] ; then
        if [ -z "$1" ]; then
            echo "No domain supplied"
            exit 1
        else
            DOMAIN=$1
        fi
    fi
fi

docker network create --subnet 10.0.0.0/8 user_network 2>/dev/null

if docker images | grep "nginx_certbot_img" ; then
    echo "img already created"
else
    cd $(dirname "$(readlink -f "$0")")
    docker build --build-arg DOMAIN=$DOMAIN -t nginx_certbot_img .
fi

cp -n -r static-html/* /docker-data/nginx/

docker run \
    -v /docker-data/letsencrypt:/etc/letsencrypt/ \
    -v /docker-data/nginx/:/usr/share/nginx:ro \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --log-driver=journald --rm \
    -p 80:80 -p 443:443 \
    --name nginx_certbot --net user_network --ip 10.0.0.42 -d \
    nginx_certbot_img:latest && echo "nginx_certbot started."
