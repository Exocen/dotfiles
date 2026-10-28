#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

if [ -z ${GITEA_RUNNER_TOKEN+x} ] || [ -z ${DOMAIN+x} ]; then
    echo "Missing env var GITEA_RUNNER_TOKEN or DOMAIN"
    exit 1
else
    if docker images | grep "gitea_runner"; then
        echo "img already created"
    else
        cd "$(dirname "$(readlink -f "$0")")" || exit 1
        docker build -t gitea_runner .
    fi
    docker run -d --rm --name gitea_runner \
        --log-driver=journald --log-opt tag="{{.Name}}" \
        -e GITEA_INSTANCE_URL="https://git.$DOMAIN" \
        -e GITEA_RUNNER_REGISTRATION_TOKEN="$GITEA_RUNNER_TOKEN" \
        -e GITEA_RUNNER_NAME=runner1 \
        -v /var/run/docker.sock:/var/run/docker.sock \
        gitea_runner:latest && echo "gitea runner started"
fi
