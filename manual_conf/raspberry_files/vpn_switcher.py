import subprocess
import sys
from random import randint
from os import listdir, path


def print_usage():
    print("Usage script.py down/up")


if len(sys.argv) != 2:
    print_usage()
    quit()


def down():
    interfaces = subprocess.run(
        ["wg", "show", "interfaces"], capture_output=True, text=True
    ).stdout.split("\n")
    for interface in interfaces:
        if interface:
            print("wg down " + interface)
            subprocess.run(["/usr/bin/wg-quick", "down", interface])


def open_file(file_path):
    if path.exists(file_path):
        with open(file_path) as file:
            return int(file.read())


def write_file(file_path, index):
    with open(file_path, "w") as file:
        file.write(str(index))


def up():
    filenames = listdir("/etc/wireguard/")
    filenames.sort()
    filepath = "/root/last_used"
    # TODO file u=rw permission + tmpfs
    index = open_file(filepath)

    if index is not None:
        next_index = 0 if index >= len(filenames) - 1 else index + 1
    else:
        next_index = randint(0, len(filenames) - 1)

    down()
    print("wg up " + filenames[next_index])
    subprocess.run(["/usr/bin/wg-quick", "up", filenames[next_index].split(".")[0]])
    write_file(filepath, next_index)


def main():
    cmd = sys.argv[-1]
    if cmd == "up":
        up()
    elif cmd == "down":
        down()
    else:
        print_usage()


if __name__ == "__main__":
    sys.exit(main())


# TODO systemd mount tmpfs
# TODO Script that
# PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -m owner --uid-owner vpn_user -j REJECT && ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -m owner --uid-owner vpn_user -j REJECT && iptables -D OUTPUT -m owner --uid-owner vpn_user -j REJECT
# PreDown = iptables -A OUTPUT -m owner --uid-owner vpn_user -j REJECT && iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -m owner --uid-owner vpn_user -j REJECT && ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -m owner --uid-owner vpn_user -j REJECT
