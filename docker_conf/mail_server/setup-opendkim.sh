#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

echo "Creating /docker-data/dms/config/opendkim"

if [ ! -d "/docker-data/dms/config/opendkim" ]; then
    if docker ps | grep "mail_server" &>/dev/null; then
        docker exec -ti mail_server setup config dkim
        docker restart mail_server
    else
        echo "mail_server must run"
    fi
else
    echo "/docker-data/dms/config/opendkim already present"
fi
