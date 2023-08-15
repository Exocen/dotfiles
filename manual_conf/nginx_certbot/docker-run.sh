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

docker stop nginx_certbot
docker rm nginx_certbot
docker build --build-arg DOMAIN=$1 -t nginx_certbot_img . && \
    \
    docker run -v /etc/letsencrypt/:/etc/letsencrypt/ -v /var/log/nginx_certbot:/var/log -p 80:80 -p 443:443 --name nginx_certbot -d --restart unless-stopped nginx_certbot_img:latest

