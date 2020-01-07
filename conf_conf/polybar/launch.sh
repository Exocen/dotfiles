#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
MPD_HOST="$HOME/.mpd/socket"

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar1 and bar2
polybar i3bar &
# polybar bar2 &

echo "Bars launched..."