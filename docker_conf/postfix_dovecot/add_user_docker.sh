#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

docker exec -it mail_server /root/add_email.sh $1 $2
