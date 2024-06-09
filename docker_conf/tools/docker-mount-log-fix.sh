#!/bin/bash
#
# Caused by docker healthcheck

mkdir /etc/systemd/system/run-docker-.mount.d
cat << EOF | sudo tee /etc/systemd/system/run-docker-.mount.d/10-silence.conf > /dev/null
[Mount]
LogLevelMax=notice
EOF
