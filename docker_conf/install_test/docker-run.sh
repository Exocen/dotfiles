#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

#TODO add args -> imgs

imgs=("debian" "ubuntu" "fedora" "alpine" "archlinux" "manjarolinux/base" "gentoo/portage")
dirpath=/docker-data-nobackup/test-install

function create() {
    img_loc="$1"
    cd "$(dirname "$(readlink -f "$0")")" || exit 1
    mkdir -p "$dirpath"
    logpath="$dirpath"/"$img_loc"
    rm -f "$logpath/$img_loc"
    tmpD=$(mktemp -d -p .)
    cp -fr ../../install.sh "$tmpD"/install.sh
    printf "#!/bin/sh\n/root/install.sh -n -l /root/logs/%s" "$img_loc" >"$tmpD"/test-engine.sh
    if docker images | grep "$img_loc"_img &>/dev/null; then
        echo "$img_loc"_img already created, removing
        docker image rm "$img_loc"_img &>/dev/null
    fi
    docker build --build-arg IMG="$img_loc" --build-arg DIR="$tmpD" -t "$img_loc"_img . 1>/dev/null

    docker run \
        -e "TZ=$(timedatectl status | grep "zone" | sed -e 's/^[ ]*Time zone: \(.*\) (.*)$/\1/g')" \
        --rm -d --name="cont_$img_loc" -v "$logpath":/root/logs "$img_loc"_img 1>/dev/null &&
        echo "$img_loc started"

    rm -r "$tmpD"
}

function clean() {
    docker wait cont_"$1" &>/dev/null
    docker kill cont_"$1" &>/dev/null
    docker rm cont_"$1" &>/dev/null
    docker image rm -f "$1"_img 1>/dev/null
    echo "$1 cleaned"
}

echo "Building ${imgs[*]}"
for img in "${imgs[@]}"; do
# TODO test with buildx -> background
    create "$img"
done

wait
echo "Running tests"
# Cleaning
for img in "${imgs[@]}"; do
    clean "$img" &
done

wait
sleep 2
echo "Results:"
# Display results
for img in "${imgs[@]}"; do
    if tail -n 1 "$dirpath"/"$img"/"$img" 2>/dev/null | grep "\[success\] Installation successful" &>/dev/null; then
        echo "$img successful"
    else
        echo "$img failed"
    fi
done
