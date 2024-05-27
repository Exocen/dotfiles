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

    if docker images | grep "$img"; then
        echo "img already created, removing"
        docker image rm "$img" 2>/dev/null
    else
        docker build --build-arg IMG="$img" -t "$img" .
    fi

    docker run \
        -v "$logpath":/root/logs \
        --rm "$img" && echo "$img started."

    docker wait "$img"
    docker image rm "$img" 2>/dev/null

done

rm install.sh
