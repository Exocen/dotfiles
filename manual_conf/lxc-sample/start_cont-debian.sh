#!/bin/bash
export CONT="debian11-$(date '+%y%m%d-%H%M%S-%2N')" &&
    lxc launch images:debian/11/cloud $CONT -p cloud-profile &&
    lxc exec $CONT -- cloud-init status -w &&
    lxc exec $CONT -- su --login tester
