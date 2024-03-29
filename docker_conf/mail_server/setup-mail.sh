#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

docker exec -ti mail_server setup "$@"
[ ! -d "/docker-data/dms/config/opendkim" ] && docker exec -ti mail_server setup config dkim && docker restart mail_server
