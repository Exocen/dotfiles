#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

[ ! -d "/docker-data/dms/config/opendkim" ] && docker exec -ti server_mail setup config dkim && docker restart server_mail
docker exec -ti server_mail setup "$@"
