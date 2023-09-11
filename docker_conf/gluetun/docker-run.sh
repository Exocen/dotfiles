#!/bin/bash

if [ `id -u` -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

docker stop gluetun
docker rm gluetun

docker run -it --rm --cap-add=NET_ADMIN --name gluetun -e VPN_SERVICE_PROVIDER=mullvad -e VPN_TYPE=openvpn \
-e OPENVPN_USER=[USER] -e SERVER_COUNTRIES=[COUNTRIES] qmcgaw/gluetun
