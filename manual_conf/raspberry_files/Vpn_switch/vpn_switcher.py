#!/usr/bin/python3

import subprocess
import sys
from random import randint
from os import listdir, path

WIREGUARD_DIR = "/etc/wireguard/"
WIREGUARD_INTPUT_DIR = "/etc/wireguard_input/"
DEFAULT_CONF = "wg0.conf"


def run_process(cmd, no_error=True):
    s = subprocess.run(cmd, capture_output=True, text=True)
    if s.returncode != 0 and no_error:
        raise Exception(s.stderr)
    if s.stdout:
        print(s.stdout)


def open_file(file_path):
    if path.exists(file_path):
        with open(file_path) as file:
            return int(file.read())


def write_file(file_path, index):
    with open(file_path, "w") as file:
        file.write(str(index))


def main():
    filenames = listdir(WIREGUARD_INTPUT_DIR)
    filenames.sort()
    filepath = path.join(WIREGUARD_DIR, "last-used")
    index = open_file(filepath)

    if index is not None:
        next_index = 0 if index >= len(filenames) - 1 else index + 1
    else:
        next_index = randint(0, len(filenames) - 1)

    next_conf = filenames[next_index]
    print("wg reload " + next_conf)
    run_process(["/usr/bin/ln", "-sf", path.join(WIREGUARD_INTPUT_DIR, next_conf), path.join(WIREGUARD_DIR, DEFAULT_CONF)])
    run_process(["/usr/bin/wg-quick", "down", "wg0"], False)
    run_process(["/usr/bin/wg-quick", "up", "wg0"])
    write_file(filepath, next_index)


if __name__ == "__main__":
    sys.exit(main())
