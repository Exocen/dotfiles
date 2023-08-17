#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

PASS_ENABLED=0

while true; do
    read -p "Do you want to activate Admin pass? " yn
    case $yn in
        [Yy]* ) PASS_ENABLED=1; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

docker stop vaultwarden
docker rm vaultwarden
docker network create --subnet 10.0.0.0/8 user_network

if [ $PASS_ENABLED -eq 1 ]; then
    PASS=`openssl rand -base64 48`
    docker run -d --name vaultwarden -v /vw-data/:/data/ -e ADMIN_TOKEN=$PASS --restart unless-stopped --net user_network --ip 10.0.0.80 vaultwarden/server:latest
    echo -e "admin pass:\n$PASS\n"
else
    sed -i '/admin_token/d' /vw-data/config.json
    docker run -d --name vaultwarden -v /vw-data/:/data/ --restart unless-stopped --net user_network --ip 10.0.0.80 vaultwarden/server:latest
fi
