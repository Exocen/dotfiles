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
    img_name=$(echo "$img_loc" | tr "/" _)
    cd "$(dirname "$(readlink -f "$0")")" || exit 1
    mkdir -p "$dirpath"
    logpath="$dirpath"/"$img_name"
    rm -f "$logpath/$img_name"
    tmpD=$(mktemp -d -p .)
    cp -fr ../../install.sh "$tmpD"/install.sh
    printf "#!/bin/sh\n/root/install.sh -n -l /root/logs/%s" "$img_name" >"$tmpD"/test-engine.sh
    if docker images | grep "$img_name"_img &>/dev/null; then
        echo "$img_name"_img already created, removing
        docker image rm "$img_name"_img &>/dev/null
    fi
    docker build --build-arg IMG="$img_loc" --build-arg DIR="$tmpD" -t "$img_name"_img . 1>/dev/null

    docker run \
        -e "TZ=$(timedatectl status | grep "zone" | sed -e 's/^[ ]*Time zone: \(.*\) (.*)$/\1/g')" \
        --rm -d --name="cont_$img_name" -v "$logpath":/root/logs "$img_name"_img 1>/dev/null &&
        echo "$img_loc started"

    rm -r "$tmpD"
}

function clean() {
    img_name=$(echo "$1" | tr "/" _)
    docker wait cont_"$img_name" &>/dev/null
    docker kill cont_"$img_name" &>/dev/null
    docker rm cont_"$img_name" &>/dev/null
    docker image rm -f "$img_name"_img 1>/dev/null
    echo "$img_name cleaned"
}

echo "Building ${imgs[*]}"
for img in "${imgs[@]}"; do
    create "$img"
done

echo "Running tests"
for img in "${imgs[@]}"; do
    clean "$img" &
done

wait
sleep 2
echo "Results:"
for img in "${imgs[@]}"; do
    img_name=$(echo "$img" | tr "/" _)
    if tail -n 1 "$dirpath"/"$img_name"/"$img_name" 2>/dev/null | grep "\[success\] Installation successful" &>/dev/null; then
        echo "$img_name successful"
    else
        echo "$img_name failed"
    fi
done
