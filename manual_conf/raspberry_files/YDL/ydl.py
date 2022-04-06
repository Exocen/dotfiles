import re
import sys
import csv
import shutil
import youtube_dl
import mutagen
import subprocess
from random import seed, randint
from time import sleep
from mutagen.easyid3 import EasyID3
from os import path
from tempfile import TemporaryDirectory

if len(sys.argv) != 4:
    print("Usage ./Script tmpram-dir dest-dir id")
    quit()

audio_format = "flac"
rng_range = 30
tmp_dir = sys.argv[-3]
error_file = path.join(tmp_dir, "ydl_error_counter")
playlist_id = sys.argv[-1]
playlist_path_location = sys.argv[-2]
retry_counter_max = 3
retry_counter = 0
loop = True


class Network_Error(Exception):
    cmd = ["/usr/bin/sudo", "/usr/bin/systemctl",
           "reload", "vpn_manager.service"]
    s = subprocess.run(cmd, capture_output=True, text=True)
    if s.returncode != 0:
        raise Exception(s.stderr)
    print(s.stdout)
    print("Vpn reloading...")


class Audio_data:
    def __init__(self, title, pid):
        self.title = title
        self.pid = pid
        self.filename = self.title + "." + audio_format

        parsed_title = re.findall(r"(.*?)\s*-\s*(.*)", title)
        if len(parsed_title) > 0 and len(parsed_title[0]) == 2:
            self.artist = parsed_title[0][0]
            self.tagtitle = parsed_title[0][1]
        else:
            self.artist = None
            self.tagtitle = None


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
            meta["title"] = audio_data.tagtitle
            meta["artist"] = audio_data.artist
            meta.save()
    if not path.exists(dest_path):
        # shutil.move -> Invalid cross-device link
        shutil.copyfile(filepath, dest_path)
        shutil.rmtree(filepath)


def generate_file_list(file_path):
    if path.exists(file_path):
        with open(file_path, newline="") as f:
            reader = csv.reader(f)
            return list(reader)[0]
    else:
        return []


def write_title_list(file_path, title_list):
    with open(file_path, "w", newline="") as csv_file:
        write = csv.writer(csv_file)
        write.writerow(title_list)


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


def connection_error():
    # Should ONLY have reload permission (visudo)
    global retry_counter
    global loop
    retry_counter = retry_counter + 1
    if retry_counter < retry_counter_max:
        raise Network_Error()
    else:
        loop = False
        return


def downloader():
    # Dl infos only
    try:
        infos = extract_info()
    except Exception:
        connection_error()

    playlist_title = infos["title"]
    file_list_path = path.join(playlist_path_location, playlist_title + ".cvs")

    # Check existing
    audio_data_list = []

    for info in infos["entries"]:
        audio_data_list.append(Audio_data(info["title"], info["id"]))

    existing_title_list = generate_file_list(file_list_path)

    audio_data_list = list(
        filter(lambda a: a.title not in existing_title_list, audio_data_list)
    )

    # Dl and tag
    if audio_data_list:
        with TemporaryDirectory(dir=tmp_dir) as tmpdirname:
            try:
                done_list = existing_title_list if existing_title_list else []
                for audio_data in audio_data_list:
                    print("DL : " + audio_data.title)
                    dl_list(audio_data, gen_ydl_options(
                        audio_format, tmpdirname))

                    tag_and_copy(audio_data, tmpdirname)
                    done_list.append(audio_data.title)
                    write_title_list(file_list_path, done_list)
                    # if not last occurence
                    if audio_data != audio_data_list[-1]:
                        sleep(randint(0, rng_range))

            except Exception:
                connection_error()


def main():
    print("Ydl Starting...")
    seed()
    global loop
    while(loop):
        try:
            downloader()
            sleep(300 + randint(0, 300))
        except Network_Error():
            pass
        except Exception():
            loop = False
            raise


if __name__ == "__main__":
    sys.exit(main())
