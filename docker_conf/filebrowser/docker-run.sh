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

if echo $CONTAINERS | grep "nginx_certbot"; then

    mkdir -p /docker-data/filebrowser
    cp -f config.yaml /docker-data/filebrowser/
    chown -R 1000:1000 /docker-data/filebrowser

#UserId:GroudId -> 1000:1000 must have folder permission
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
    ---net user_network --ip 10.0.0.85 \
    ghcr.io/gtsteffaniak/filebrowser:stable

else

    mkdir -p /docker-data/filebrowser
    cp -f no-auth-config.yaml /docker-data/filebrowser/config.yaml
    chown -R 1000:1000 /docker-data/filebrowser

#UserId:GroudId -> 1000:1000 must have folder permission
#No auth : copy no-auth-config.yaml to /docker-data/filebrowser

docker run \
    --name filebrowser --log-driver=journald --log-opt tag="{{.Name}}" --rm -d \
    --health-cmd="curl -f http://localhost:8080/health || exit 1" \
    --health-interval=30s \
    --health-timeout=3s \
    --health-start-period=10s \
    --health-retries=3 \
    -v "/docker-data/filebrowser":"/home/filebrowser/data" \
    -v "$FILEBROWSER_PATH":/folder \
    -u 1000:1000 \
    -p 80:80 \
    ghcr.io/gtsteffaniak/filebrowser:stable
fi
