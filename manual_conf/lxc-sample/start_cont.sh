#!/bin/bash
export CONT=`date +%s | sha256sum | base64 | head -c 32 ; echo` && lxc launch images:debian/11/cloud $CONT -p cloud-profile && lxc exec $CONT -- cloud-init status -w && lxc exec $CONT -- su --login exo
