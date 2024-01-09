#!/bin/bash

if [ $(id -u) -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

if [ -z ${VPN_KEY+x} ]; then
    if [ -z "$1" ]; then
        echo "No key supplied"
        exit 1
    else
        VPN_KEY=$1
    fi
fi

docker run -d --rm --cap-add=NET_ADMIN --name gluetun --log-driver=journald -e VPN_SERVICE_PROVIDER=mullvad -e VPN_TYPE=openvpn \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    -p 9091:9091 \
    -p 51413:51413 \
    -p 51413:51413/udp \
    -e SERVER_COUNTRIES="USA" -e OPENVPN_USER=$VPN_KEY qmcgaw/gluetun && echo "gluetun started."

# Optional environment variables

#  -e  SERVER_COUNTRIES: Comma separated list of countries
#  -e  SERVER_CITIES: Comma separated list of cities
#  -e  SERVER_HOSTNAMES: Comma separated list of server hostnames
#  -e  ISP: Comma separated list of ISPs
#  -e  OWNED_ONLY: If the VPN server is owned by Mullvad. It defaults to no, meaning it includes all servers. It can be set to yes.
#  -e  VPN_ENDPOINT_PORT: Custom OpenVPN server endpoint port to use
#        For TCP: 80, 443 or 1401
#        For UDP: 53, 1194, 1195, 1196, 1197, 1300, 1301, 1302, 1303 or 1400
#        It defaults to 443 for TCP and 1194 for UDP
#  -e  VPN_ENDPOINT_PORT: Custom Wireguard server endpoint port to use
