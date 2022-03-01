# import subprocess, sys
# from random import randint

# up()
# filenames = sort ls /etc/wireguard/
# file u=rw permission
# file -> last-used -> tmpfs
# if file:
#   index = read file
#   next_index = 0 if index >= len(filenames)-1 else index+1
# else:
#   next_index = rng(0, len(filenames)-1)
# down()
# /usr/bin/wg-quick up (filenames[next_index])
# write file(next_index)

# down()
# interface = wg show interfaces
# loop : wg-quick down interface

# main
# 2 args => down up
# up -> up()
# down -> down()

# TODO systemd mount tmpfs
# TODO Script that
# PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -m owner --uid-owner vpn_user -j REJECT && ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -m owner --uid-owner vpn_user -j REJECT && iptables -D OUTPUT -m owner --uid-owner vpn_user -j REJECT
# PreDown = iptables -A OUTPUT -m owner --uid-owner vpn_user -j REJECT && iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -m owner --uid-owner vpn_user -j REJECT && ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -m owner --uid-owner vpn_user -j REJECT
