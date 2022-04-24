import subprocess
import sys
from random import randint
from os import listdir, path

WIREGUARD_DIR = "/etc/wireguard/"
WIREGUARD_INTPUT_DIR = "/etc/wireguard_input/"
DEFAULT_CONF = "wg0.conf"


def run_process(cmd):
    s = subprocess.run(cmd, capture_output=True, text=True)
    if s.returncode != 0:
        raise Exception(s.stderr)
    print(s.stdout)
    return s


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
    # TODO Bad
    filepath = path.join(WIREGUARD_DIR, "last-used")
    index = open_file(filepath)

    if index is not None:
        next_index = 0 if index >= len(filenames) - 1 else index + 1
    else:
        next_index = randint(0, len(filenames) - 1)

    next_conf = filenames[next_index].split(".")[0]
    print("wg reload " + next_conf)
    run_process(["/usr/bin/ln", "-sf", path.join(WIREGUARD_INTPUT_DIR, next_conf), path.join(WIREGUARD_DIR, DEFAULT_CONF)])
    run_process(["/usr/bin/systemctl", "restart", "wg-quick@wg0"])
    write_file(filepath, next_index)


if __name__ == "__main__":
    sys.exit(main())
