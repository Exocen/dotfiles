#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
else
    if [ -z ${FILEBROWSER_PATH+x} ] ; then
        if [ -z "$1" ]; then
            echo "No path supplied"
            exit 1
        else
            FILEBROWSER_PATH=$1
        fi
    fi
fi

cd "$(dirname "$(readlink -f "$0")")" || exit 1

mkdir -p /docker-data/filebrowser
cp -n config.yaml /docker-data/filebrowser/
chown -R 1000:1000 /docker-data/filebrowser

#UserId:GroudId -> 1000:1000 must have folder permission
#If no auth : copy no-auth-config.yaml to /docker-data/filebrowser
#Get the admin pass with:
#docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' filebrowser | grep FILEBROWSER_ADMIN_PASSWORD

docker run \
    --name filebrowser --log-driver=journald --log-opt tag="{{.Name}}" --rm -d \
    --health-cmd="curl -f http://localhost:8080/health || exit 1" \
    --health-interval=30s \
    --health-timeout=3s \
    --health-start-period=10s \
    --health-retries=3 \
    -e "FILEBROWSER_ADMIN_PASSWORD=$(openssl rand -base64 48)" \
    -v "/docker-data/filebrowser":"/home/filebrowser/data" \
    -v "$FILEBROWSER_PATH":/folder \
    -u 1000:1000 \
    -p 80:80 \
    ghcr.io/gtsteffaniak/filebrowser:stable
