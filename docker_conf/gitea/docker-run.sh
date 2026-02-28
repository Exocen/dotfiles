#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
     echo "Must be run as root"
     exit 1
 fi

docker run  \
    -d --name gitea --rm \
    -v /docker-data/gitea/:/data/ \
    -v /etc/localtime:/etc/localtime:ro \
    --log-driver=journald --log-opt tag="{{.Name}}" -e USER_UID=1000 -e USER_GID=1000 \
    -p 22:22 \
    --net user_network --ip 10.0.0.81 gitea/gitea && echo "gitea started"

# /docker-data/gitea/gitea/conf/app.ini
## allow push to create
# Repository
#   ENABLE_PUSH_CREATE_ORG = true
## disable http auth (allow ssh)
# Service
#   ENABLE_BASIC_AUTHENTICATION = false
# Server
#   SSH_PORT = 2222
