#!/bin/bash
#TODO redirection nginx "3000:3000"

docker run  \
    -d --name gitea --rm \
    -v /docker-data/gitea/:/data/ \
    -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
    --log-driver=journald -e USER_UID=1000 -e USER_GID=1000 \
    -p 82:22 \
    --net user_network --ip 10.0.0.81 gitea/gitea:main-nightly && echo "gitea started."
