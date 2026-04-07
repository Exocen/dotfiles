#!/bin/bash

#if ip a | grep inet6; then
if [ `cat /proc/sys/net/ipv6/conf/all/disable_ipv6` -ne 1 ]; then
    echo "Ipv6 detected, disabling"
    if [ ! -f "/etc/sysctl.conf" ]; then
        file_path="/etc/sysctl.conf"
    else
        file_path="/etc/sysctl.d/ipv6-disabled"
        rm -f $file_path
    fi
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> $file_path
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> $file_path
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> $file_path
    sysctl -p
fi

if [ `cat /proc/sys/net/ipv6/conf/all/disable_ipv6` -eq 1 ]; then
    echo "ipv6 disabled"
else
    echo "ipv6 still active !"
    exit 1
fi
