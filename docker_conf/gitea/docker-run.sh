#!/bin/bash

networks:
  gitea:
    external: false

services:
  server:
    image: gitea/gitea:main-nightly
    container_name: gitea
    environment:
      - USER_UID=1000
      - USER_GID=1000
    restart: always
    networks:
      - gitea
    ports:
      - "3000:3000"
      - "222:22"

docker run  \
        -d --name gitea --rm \
        -v /docker-data/gitea/:/data/ \
        -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
        --log-driver=journald -e USER_UID=1000 -e USER_GID=1000 \
        --net user_network --ip 10.0.0.81 gitea/gitea:main-nightly && echo "gitea started."
