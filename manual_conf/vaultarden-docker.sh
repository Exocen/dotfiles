#!/bin/bash

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

PASS=`openssl rand -base64 48`
if [ $PASS_ENABLED -eq 1 ]; then
docker run -d --name vaultwarden -v /vw-data/:/data/ -e ADMIN_TOKEN=$PASS --restart unless-stopped --net user_work --ip 10.0.0.80 vaultwarden/server:latest
else
    docker run -d --name vaultwarden -v /vw-data/:/data/ -e DISABLE_ADMIN_TOKEN=true --restart unless-stopped --net user_work --ip 10.0.0.80 vaultwarden/server:latest
fi
echo -e "admin pass:\n$PASS\n"
