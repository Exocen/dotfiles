#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

# First time conf + password change
# mail.domain.com/?admin -> user= admin pass= /docker-data/snappymail/_data_/_default_/admin_password.txt

docker run -d --rm --log-driver=journald --log-opt tag="{{.Name}}" \
    -v /etc/localtime:/etc/localtime:ro \
    -v /docker-data/snappymail:/var/lib/snappymail \
    --net user_network --ip 10.0.0.82 \
    --name=snappymail \
    djmaze/snappymail && echo "Snappymail started."
