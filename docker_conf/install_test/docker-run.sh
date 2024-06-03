#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Must be run as root"
    exit 1
fi

# default value if no arguments/img are passed
imgs=("debian" "ubuntu" "fedora" "alpine" "archlinux" "manjarolinux/base")
dirpath=/docker-data-nobackup/install-test-logs
LOCAL=$(dirname "$(readlink -f "$0")")

if [ "$#" == 0 ]; then
    echo "No args given testing on ${imgs[*]}"
else
    imgs=("$@")
    echo "Testing on ${imgs[*]}"
fi

function clean() {
    img_name="$(echo "$1" | tr ":/" _)"
    if ! docker wait cont_"$img_name" &>/dev/null; then
        docker kill cont_"$img_name" &>/dev/null
        docker rm cont_"$img_name" &>/dev/null
    fi
    docker image rm -f "$img_name"_img 1>/dev/null
    echo "$img_name cleaned"
}

function create() {
    img="$1"
    img_name="$(echo "$img" | tr ":/" _)"
    logpath="$dirpath"/"$img_name"
    tmpD="$(mktemp -d -p /var/tmp/)"

    rm -fr "$logpath"
    cp -fr "$LOCAL/../../install.sh" "$tmpD"/install.sh
    cp "$LOCAL/dockerfile" "$tmpD"
    printf "#!/bin/sh\n/root/install.sh -n -l /root/%s/logs" "$img_name" >"$tmpD"/test-engine.sh
    cd "$tmpD" || exit 1
    if docker images | grep "$img_name"_img &>/dev/null; then
        echo "$img_name"_img already created, removing
        docker image rm "$img_name"_img &>/dev/null
    fi
    docker build --build-arg IMG="$img" --build-arg IMGN="$img_name" -t "$img_name"_img . 1>/dev/null

    docker run \
        -e "TZ=$(timedatectl status | grep "zone" | sed -e 's/^[ ]*Time zone: \(.*\) (.*)$/\1/g')" \
        --rm -d --name=cont_"$img_name" -v "$logpath":/root/"$img_name" "$img_name"_img 1>/dev/null &&
        echo "$img" started
    rm -r "$tmpD"
}

mkdir -p "$dirpath"

# 3 loops: Img building + run, img and cont cleaning (except logs), logs reading
echo "* Building ${imgs[*]}"
for img1 in "${imgs[@]}"; do
    create "$img1" &
done
wait

echo "* Running tests"
for img2 in "${imgs[@]}"; do
    clean "$img2" &
done
wait && sleep 2

echo "* Results"
for img3 in "${imgs[@]}"; do
    img_name="$(echo "$img3" | tr ":/" _)"
    if tail -n 1 "$dirpath"/"$img_name"/logs 2>/dev/null | grep "\[success\] Installation successful" &>/dev/null; then
        echo "$img_name successful"
    else
        echo "$img_name failed"
    fi
done
