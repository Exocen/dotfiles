#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
	echo "Must be run as root"
	exit 1
fi

if [ -z ${GITEA_RUNNER_TOKEN+x} ] || [ -z ${DOMAIN+x} ]; then
	echo "Missing env var GITEA_RUNNER_TOKEN or DOMAIN"
	exit 1
else
	docker run -d --rm --name gitea_runner \
	--log-driver=journald --log-opt tag="{{.Name}}" \
	-e GITEA_INSTANCE_URL="https://git.$DOMAIN" \
	-e GITEA_RUNNER_REGISTRATION_TOKEN="$GITEA_RUNNER_TOKEN" \
	-e GITEA_RUNNER_NAME=runner1 \
	-v /var/run/docker.sock:/var/run/docker.sock \
	docker.io/gitea/runner:latest && echo "gitea runner started"
fi
