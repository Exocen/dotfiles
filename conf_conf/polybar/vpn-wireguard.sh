#!/bin/sh

#TODO add multiple config + click to disconnect or change

connection_status() {
    connection=$(sudo wg show 2>/dev/null | head -n 1 | awk '{print $NF }')

    if [[ ! -z "$connection" ]]; then
        echo "1"
    else
        echo "2"
    fi
}


if [ "$(connection_status)" = "1" ]; then
    echo "%{u#808080}%{+u}%{F#808080}ﱾ%{F-}"
else
    echo
fi
