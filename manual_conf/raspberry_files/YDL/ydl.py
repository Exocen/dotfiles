import re
import sys
import csv
import shutil
import youtube_dl
import mutagen
import subprocess
import os
from time import sleep
from random import randint
from mutagen.easyid3 import EasyID3
from os import path, listdir
from tempfile import TemporaryDirectory

if len(sys.argv) != 4:
    print("Usage ./Script tmpram-dir dest-dir id")
    quit()

audio_format = "flac"
rng_range = 30
tmp_dir = sys.argv[-3]
error_file = path.join(tmp_dir, "ydl_tries_errors")
playlist_id = sys.argv[-1]
playlist_path_location = sys.argv[-2]


class Audio_data:
    def __init__(self, title, pid):
        self.title = title
        self.pid = pid
        parsed_title = re.findall(r"(.*?)\s*-\s*(.*)", title)
        if len(parsed_title) > 0 and len(parsed_title[0]) == 2:
            self.artist = parsed_title[0][0]
            self.title = parsed_title[0][1]
            self.filename = self.artist + " - " + self.title + "." + audio_format
        else:
            self.artist = None
            self.filename = self.title + "." + audio_format


def dl_list(audio_data, ydl_opts):
    with youtube_dl.YoutubeDL(ydl_opts) as ydl:
        ydl.download([audio_data.pid])


def extract_info():
    with youtube_dl.YoutubeDL({"quiet": True}) as ydl:
        return ydl.extract_info(playlist_id, download=False)


def tag_and_copy(audio_data, pytemp_dir):
    dest_path = path.join(playlist_path_location, audio_data.filename)
    filepath = path.join(pytemp_dir, audio_data.filename)
    if audio_data.artist:
        # if format/title = 'artist - song' use id3 tags
        try:
            meta = EasyID3(filepath)
        except mutagen.id3.ID3NoHeaderError:
            meta = mutagen.File(filepath, easy=True)
            meta["title"] = audio_data.title
            meta["artist"] = audio_data.artist
            meta.save()
    if not path.exists(dest_path):
        shutil.copyfile(filepath, dest_path)


def generate_file_list(file_path):
    if path.exists(file_path):
        with open(file_path, newline="") as f:
            reader = csv.reader(f)
            return list(reader)[0]
    else:
        return listdir(playlist_path_location)


def write_title_list(file_path):
    existing_title_list = listdir(playlist_path_location)
    with open(file_path, "w", newline="") as csv_file:
        write = csv.writer(csv_file)
        write.writerow(existing_title_list)


def run_process(cmd):
    s = subprocess.run(cmd, capture_output=True, text=True)
    if s.returncode != 0:
        raise Exception(s.stderr)
    print(s.stdout)
    return s


def gen_ydl_options(audio_format, tmpdirname):
    return {
        "extractaudio": True,
        "format": "bestaudio/best",
        "quiet": True,
        "postprocessors": [
            {
                "key": "FFmpegExtractAudio",
                "preferredcodec": audio_format,
            }
        ],
        "outtmpl": tmpdirname + "/%(title)s.%(ext)s",
    }


def open_file():
    if path.exists(error_file):
        with open(error_file) as file:
            return int(file.read())


def write_file(index):
    with open(error_file, "w") as file:
        file.write(str(index))


def manage_error(error_tries):
    write_file(error_tries)
    run_process(
        ["/usr/bin/sudo", "/usr/bin/systemctl", "restart", "vpn_manager.service"]
    )


def main():

    # Error management -> error -> switch vpn up to 3 times
    # error/mail on the 3 error -> then stop running
    error_ydl = open_file()
    error_tries = error_ydl if error_ydl is not None else 0
    if error_tries == 3:
        write_file(error_tries + 1)
        sys.exit(1)
    elif error_tries > 3:
        print("Ydl Stopped: Too much retries")
        return

    # Dl infos only
    try:
        infos = extract_info()
    except Exception as exception:
        manage_error(error_tries + 1)
        # TODO why raise does not work
        print(exception)
        sys.exit(1)

    playlist_title = infos["title"]
    file_list_path = path.join(tmp_dir, playlist_title + ".cvs")

    # Check existing
    audio_data_list = []
    for info in infos["entries"]:
        audio_data_list.append(Audio_data(info["title"], info["id"]))

    existing_title_list = generate_file_list(file_list_path)

    audio_data_list = list(
        filter(lambda a: a.filename not in existing_title_list, audio_data_list)
    )

    # Dl and tag
    if audio_data_list:
        with TemporaryDirectory(dir=tmp_dir) as tmpdirname:
            try:
                for audio_data in audio_data_list:
                    print("DL : " + audio_data.filename)
                    dl_list(audio_data, gen_ydl_options(audio_format, tmpdirname))
                    tag_and_copy(audio_data, tmpdirname)
                    # if not last occurence
                    if audio_data != audio_data_list[-1]:
                        sleep(randint(0, rng_range))
                write_title_list(file_list_path)
            # TODO find and add 405
            except Exception as exception:
                manage_error(error_tries + 1)
                # TODO why raise does not work
                print(exception)
                sys.exit(1)
    else:
        write_title_list(file_list_path)
    if error_tries != 0:
        os.remove(error_file)


if __name__ == "__main__":
    sys.exit(main())
