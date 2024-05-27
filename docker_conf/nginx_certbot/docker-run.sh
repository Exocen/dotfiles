#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
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

cd "$(dirname "$(readlink -f "$0")")" || exit 1

if docker images | grep "nginx_certbot_img" ; then
    echo "img already created"
else
    docker build --build-arg DOMAIN="$DOMAIN" -t nginx_certbot_img .
fi


tmpD=$(mktemp -d)
cp -n -r static-html/* "$tmpD"/
cd "$tmpD" || exit 1 
find . -type f -print0 | xargs -0 sed -i 's/\[DOMAIN\]/'"$DOMAIN"'/g'
mkdir -p /docker-data/nginx/
cp -n -r "$tmpD"/* /docker-data/nginx/
rm -rf "$tmpD"

docker run \
    -v /docker-data/letsencrypt:/etc/letsencrypt/ \
    -v /docker-data/nginx/:/usr/share/nginx:ro \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --log-driver=journald --log-opt tag="{{.Name}}" --rm \
    --name nginx_certbot --net host -d \
    nginx_certbot_img:latest && echo "nginx_certbot started"
