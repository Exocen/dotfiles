#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

cp -fr ../../install.sh .

imgs=("debian" "ubuntu" "fedora" "alpine" "centos" "archlinux")
dirpath=/docker-data-nobackup/test-install

for img in "${imgs[@]}"; do

    cd "$(dirname "$(readlink -f "$0")")" || exit 1
    mkdir -p "$dirpath"
    logpath="$dirpath"/"$img"
    rm -f "$logpath/$img" 2>/dev/null

    printf "#!/bin/sh\n/root/install.sh -n -l /root/logs/%s" "$img" >test-engine.sh

    if docker images | grep "$img"_img &>/dev/null; then
        echo "$img"_img already created, removing
        docker image rm "$img"_img &>/dev/null
    fi
    docker build --build-arg IMG="$img" -t "$img"_img . 1>/dev/null

    docker run \
        -e "TZ=$(timedatectl status | grep "zone" | sed -e 's/^[ ]*Time zone: \(.*\) (.*)$/\1/g')" \
        --rm -d --name="cont_$img" -v "$logpath":/root/logs "$img"_img 1>/dev/null &&
        echo "$img started"

    rm test-engine.sh

done

echo "Running tests"
# Cleaning
rm install.sh
for img in "${imgs[@]}"; do
    # while [ "$(docker inspect -f "{{.State.Running}}" cont_"$img" 2>/dev/null)" == "true" ]; do
    docker wait cont_"$img" &>/dev/null
    docker kill cont_"$img" &>/dev/null
    docker rm cont_"$img" &>/dev/null
    docker image rm -f "$img"_img 1>/dev/null
    echo "$img cleaned"
done

sleep 4
echo "Results:"
# Display results
for img in "${imgs[@]}"; do
    if tail -n 1 "$dirpath"/"$img"/"$img" 2>/dev/null | grep "\[success\] Installation successful" &>/dev/null; then
        echo "$img successful"
    else
        echo "$img failed"
    fi
done
