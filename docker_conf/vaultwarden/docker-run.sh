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

docker stop vaultwarden &>/dev/null
docker rm vaultwarden &>/dev/null
docker network create --subnet 10.0.0.0/8 user_network 2>/dev/null

#TODO --restart on-failure[:max-retries]
if [ $PASS_ENABLED -eq 1 ]; then
    PASS=`openssl rand -base64 48`
    docker run -d --name vaultwarden -v /docker-data/vaultwarden-data/:/data/ --log-driver=journald -e ADMIN_TOKEN=$PASS -e LOG_FILE=/var/log/vaultwarden.log  --restart unless-stopped --net user_network --ip 10.0.0.80 vaultwarden/server:latest
    echo -e "admin pass:\n$PASS\nUse it on https://VW-DOMAIN/admin"
else
 [[ -f /docker-data/vaultwarden-data/config.json ]] &&  sed -i '/admin_token/d' /docker-data/vaultwarden-data/config.json
    docker run -d --name vaultwarden -v /docker-data/vaultwarden-data/:/data/ --log-driver=journald -e LOG_FILE=/var/log/vaultwarden.log  --restart unless-stopped --net user_network --ip 10.0.0.80 vaultwarden/server:latest
fi
