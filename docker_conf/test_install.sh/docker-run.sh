#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi


cp -fr ../../install.sh .

imgs=("debian" "ubuntu" "fedora" "alpine")


for img in "${imgs[@]}"; do
    logpath=/docker-data-nobackup/test-install/"$img"
    mkdir -p "$logpath"
    cd "$(dirname "$(readlink -f "$0")")" || exit 1

    if docker images | grep "$img" ; then
        echo "img already created, removing"
        docker image rm "$img" || exit 1
    else
        docker build --build-arg IMG="$img" -t "$img" .
    fi

    docker run \
        --log-driver=journald --log-opt tag="{{.Name}}" --rm \
        -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
        -v "$logpath":/root/logs \
        "$img" && echo "$img started."

    docker wait "$img"
    docker image rm "$img"

done

rm install.sh
