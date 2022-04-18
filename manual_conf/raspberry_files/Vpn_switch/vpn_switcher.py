import subprocess
import sys
from time import sleep
from random import randint
from os import listdir, path


def print_usage():
    print("Usage script.py down/up/reload")


if len(sys.argv) != 2:
    print_usage()
    quit()


def run_process(cmd):
    s = subprocess.run(cmd, capture_output=True, text=True)
    if s.returncode != 0:
        raise Exception(s.stderr)
    print(s.stdout)
    return s


def ping_check():
    run_process(["/usr/bin/ping", "ping", "1.1.1.1", "-c", "5"])


def down():
    interfaces = run_process(["wg", "show", "interfaces"]).stdout.split("\n")
    for interface in interfaces:
        if interface:
            print("wg down " + interface)
            run_process(["/usr/bin/wg-quick", "down", interface])


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
    filepath = "/root_tmp/last_used"
    index = open_file(filepath)

    if index is not None:
        next_index = 0 if index >= len(filenames) - 1 else index + 1
    else:
        next_index = randint(0, len(filenames) - 1)

    down()
    next_conf = filenames[next_index].split(".")[0]
    print("wg up " + next_conf)
    run_process(["/usr/bin/wg-quick", "up", next_conf])
    write_file(filepath, next_index)
    sleep(5)
    ping_check()


def reload():
    down()
    up()


def main():
    cmd = sys.argv[-1]
    if cmd == "up":
        up()
    elif cmd == "down":
        down()
    elif cmd == "reload":
        reload()
    else:
        print_usage()


if __name__ == "__main__":
    sys.exit(main())
