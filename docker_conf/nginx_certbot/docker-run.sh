#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z "$1" ]; then
        echo "No domain supplied"
        exit 1
    elif [ "$1" == "default" ]; then
        DOMAIN=`hostnamectl --static`
    else
        DOMAIN=$1
    fi
fi

docker network create --subnet 10.0.0.0/8 user_network 2>/dev/null

if docker images | grep "nginx_certbot_img" ; then
    echo "img already created"
else
    cd $(dirname "$(readlink -f "$0")")
    docker build --build-arg DOMAIN=$DOMAIN -t nginx_certbot_img .
fi

docker run \
    -v /docker-data/letsencrypt:/etc/letsencrypt/ \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --log-driver=journald --rm \
    -p 80:80 -p 443:443 \
    --name nginx_certbot --net user_network --ip 10.0.0.42 -d \
    nginx_certbot_img:latest && echo "nginx_certbot started."
