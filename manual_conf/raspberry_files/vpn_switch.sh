#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "$0: usage : script up/down"
    exit 3
fi

if [ "$1" == "up" ]; then echo hi; fi
    iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -m owner --uid-owner vpn_user -j REJECT
    ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -m owner --uid-owner vpn_user -j REJECT
    iptables -D OUTPUT -m owner --uid-owner vpn_user -j REJECT
    ip6tables -D OUTPUT -m owner --uid-owner vpn_user -j REJECT
elif [ "$1" == "down" ]; then 
    iptables -I OUTPUT -m owner --uid-owner vpn_user -j REJECT
    ip6tables -I OUTPUT -m owner --uid-owner vpn_user -j REJECT
    iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -m owner --uid-owner vpn_user -j REJECT
    ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -m owner --uid-owner vpn_user -j REJECT
else
    echo "$0: usage : script up/down"
    exit 3
fi