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


if [ -z ${GITEA_RUNNER_TOKEN+x} ] || [ -z ${DOMAIN+x} ]; then
	exit 0
fi
docker run -d --rm --name runner1 --log-driver=journald --log-opt tag="{{.Name}}" -e GITEA_INSTANCE_URL="https://git.$DOMAIN" -e GITEA_RUNNER_REGISTRATION_TOKEN="$GITEA_RUNNER_TOKEN" -e GITEA_RUNNER_NAME=runner1 -v /var/run/docker.sock:/var/run/docker.sock docker.io/gitea/runner:3 && echo "gitea runner1 started"

docker run -d --rm --name runner2 --log-driver=journald --log-opt tag="{{.Name}}" -e GITEA_INSTANCE_URL="https://git.$DOMAIN" -e GITEA_RUNNER_REGISTRATION_TOKEN="$GITEA_RUNNER_TOKEN" -e GITEA_RUNNER_NAME=runner2 -v /var/run/docker.sock:/var/run/docker.sock docker.io/gitea/runner:3 && echo "gitea runner2 started"


# /docker-data/gitea/gitea/conf/app.ini
## allow push to create
# Repository
#   ENABLE_PUSH_CREATE_ORG = true
## disable http auth (allow ssh)
# Service
#   ENABLE_BASIC_AUTHENTICATION = false
# Server
#   SSH_PORT = 2222
