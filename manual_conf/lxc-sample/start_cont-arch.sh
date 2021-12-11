#!/bin/bash
export CONT="archlinux-$(date '+%y%m%d-%H%M%S-%2N')" &&
    lxc launch images:archlinux/current/cloud $CONT -p cloud-profile &&
    lxc exec $CONT -- cloud-init status -w &&
    lxc exec $CONT -- su --login exo
