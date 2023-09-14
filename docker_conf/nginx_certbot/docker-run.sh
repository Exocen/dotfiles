#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z "$1" ]; then
        echo "No domain supplied"
        exit 1
    fi
fi

docker network create --subnet 10.0.0.0/8 user_network 2>/dev/null
docker images | grep "nginx_certbot_img" || docker build --build-arg DOMAIN=$1 -t nginx_certbot_img .

docker run \
    -v /docker-data/letsencrypt:/etc/letsencrypt/ \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --log-driver=journald --rm \
    -p 80:80 -p 443:443 \
    --name nginx_certbot --net user_network --ip 10.0.0.42 -d \
    nginx_certbot_img:latest && echo "nginx_certbot started."
