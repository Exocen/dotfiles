#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

docker run -d --rm --log-driver=journald --log-opt tag="{{.Name}}" \
    -e "TZ=$(timedatectl status | grep "zone" | sed -e 's/^[ ]*Time zone: \(.*\) (.*)$/\1/g')" \
    -e PUID=1000 \
    -e PGID=1000 \
    -v /docker-data/openvpn:/etc/openvpn\
    -p 1194:1194/udp --cap-add=NET_ADMIN\
    --name=openvpn\
    kylemanna/openvpn:latest && echo "Openvpn started."
