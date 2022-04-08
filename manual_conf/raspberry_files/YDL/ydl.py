import re
import csv
import shutil
import youtube_dl
import mutagen
import subprocess
import logging
from random import seed, randint
from time import sleep
from mutagen.easyid3 import EasyID3
from os import path
from tempfile import TemporaryDirectory

logging.basicConfig(level=logging.INFO)
log = logging.getLogger('YDL')
audio_format = "flac"
rng_range = 30
sleep_cooldown = 5
cooldown = 300
params_location = path.join(path.dirname(path.realpath(__file__)), "ydl_param.csv")
retry_counter_max = 3


class Main:

    def __init__(self):
        self.tmp_dir = None
        self.playlist_id = None
        self.playlist_path_location = None
        self.params_list = self.get_param_list()
        self.retry_counter = 0
        self.loop = True
        self.last_dl_file = None

    def get_param_list(self):
        rows = []
        with open(params_location, 'r') as csvfile:
            csvreader = csv.reader(csvfile)
            # extracting each data row one by one
            for row in csvreader:
                rows.append(row)
        log.debug(f'Using new parameters -> {rows}')
        return rows

    def dl_list(self, audio_data, ydl_opts):
        with youtube_dl.YoutubeDL(ydl_opts) as ydl:
            ydl.download([audio_data.pid])

    def extract_info(self):
        with youtube_dl.YoutubeDL({"quiet": True}) as ydl:
            return ydl.extract_info(self.playlist_id, download=False)

    def tag_and_copy(self, audio_data, tmpdirname):
        dest_path = path.join(self.playlist_path_location, audio_data.filename)
        log.debug(self.playlist_path_location)
        log.debug(audio_data.filename)
        log.debug(dest_path)
        filepath = path.join(tmpdirname, audio_data.filename)
        log.debug(f'Moving {filepath} -> {dest_path}')
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
            shutil.copyfile(filepath, dest_path)

    def get_file_list(self, file_path):
        log.debug(f"getting titles from {file_path}")
        if path.exists(file_path):
            with open(file_path, newline="") as f:
                reader = csv.reader(f)
                return list(reader)[0]
        else:
            return []

    def write_title_list(self, file_path, title_list):
        log.debug(f"writing titles to {file_path}")
        with open(file_path, "w", newline="") as csv_file:
            write = csv.writer(csv_file)
            write.writerow(title_list)

    def file_hook(self, d):
        if d['status'] == 'finished':
            pre, ext = path.splitext(path.basename(d['filename']))
            self.last_dl_file = pre + '.' + audio_format

    def gen_ydl_options(self, tmpdirname):
        return {
            "extractaudio":
            True,
            "format":
            "bestaudio/best",
            "quiet":
            True,
            "postprocessors": [{
                "key": "FFmpegExtractAudio",
                "preferredcodec": audio_format,
            }],
            "outtmpl":
            tmpdirname + "/%(title)s.%(ext)s",
            'progress_hooks': [self.file_hook],
        }

    def connection_error(self, exception):
        self.retry_counter = self.retry_counter + 1
        if self.retry_counter < retry_counter_max:
            raise Network_Error()
        else:
            self.loop = False
            raise exception

    def downloader(self):
        # Dl infos only
        try:
            infos = self.extract_info()
        except Exception as exception:
            self.connection_error(exception)

        playlist_title = infos["title"]
        file_list_path = path.join(self.playlist_path_location, playlist_title + ".cvs")

        # Check existing
        audio_data_list = []

        for info in infos["entries"]:
            audio_data_list.append(Audio_data(info["title"], info["id"]))

        existing_title_list = self.get_file_list(file_list_path)

        audio_data_list = list(
            filter(lambda a: a.title not in existing_title_list,
                   audio_data_list))

        # Dl and tag
        if audio_data_list:
            try:
                done_list = existing_title_list if existing_title_list else []
                for audio_data in audio_data_list:
                    with TemporaryDirectory(dir=self.tmp_dir) as tmpdirname:
                        log.info("Downloading: " + audio_data.title)
                        self.dl_list(audio_data, self.gen_ydl_options(tmpdirname))
                        audio_data.filename = self.last_dl_file
                        self.tag_and_copy(audio_data, tmpdirname)
                        done_list.append(audio_data.title)
                        self.write_title_list(file_list_path, done_list)
                        # if not last occurence
                        if audio_data != audio_data_list[-1]:
                            sleep(randint(sleep_cooldown, sleep_cooldown + rng_range))

            except Exception as exception:
                self.connection_error(exception)

    def run(self):
        log.debug("YDL Starting...")
        seed()
        while (self.loop):
            try:
                for params in self.params_list:
                    self.tmp_dir = params[0]
                    self.playlist_path_location = params[1]
                    self.playlist_id = params[2]
                    self.downloader()
                sleep(cooldown + randint(0, cooldown))
            except Network_Error:
                pass
            except Exception:
                self.loop = False
                raise


class Network_Error(Exception):

    def __init__(self):
        log.info("Vpn reloading...")
        # Should ONLY have reload permission (visudo)
        cmd = ["/usr/bin/sudo", "/usr/bin/systemctl", "reload", "vpn_manager.service"]
        s = subprocess.run(cmd, capture_output=True, text=True)
        if s.returncode != 0:
            raise Exception(s.stderr)
        if s.stdout:
            log.warning(s.stdout)
        sleep(sleep_cooldown)
        log.debug("Vpn reloaded")


class Audio_data:

    def __init__(self, title, pid):
        self.title = title
        self.pid = pid
        self.filename = None
        parsed_title = re.findall(r"(.*?)\s*-\s*(.*)", title)
        if len(parsed_title) > 0 and len(parsed_title[0]) == 2:
            self.artist = parsed_title[0][0]
            self.tagtitle = parsed_title[0][1]
        else:
            self.artist = None
            self.tagtitle = None


if __name__ == "__main__":
    Main().run()
