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
post_dl_cooldown = 15
post_vpn_cooldown = 30
loop_cooldown = 300
# Script dir
params_location = path.join(path.dirname(path.realpath(__file__)), "ydl_param.csv")
retry_counter_max = 3


class Main:

    def __init__(self):
        self.tmp_dir = None
        self.playlist_id = None
        self.playlist_path_location = None
        self.params_list = self.get_param_list()
        log.debug(f'Using new parameters -> {self.params_list}')
        self.retry_counter = 0
        self.loop = True
        self.last_dl_file = None
        self.audio_transform = None

    def get_title_list(self, file_path):
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

    def get_param_list(self):
        rows = []
        with open(params_location, 'r') as csvfile:
            csvreader = csv.reader(csvfile)
            # extracting each data row one by one
            for row in csvreader:
                rows.append(row)
        return rows

    def file_hook(self, d):
        # Get video filename -> audio filename
        if d['status'] == 'finished':
            pre, ext = path.splitext(path.basename(d['filename']))
            self.last_dl_file = pre + '.' + audio_format

    def gen_ydl_options(self, tmpdirname):
        opts = {
            "extractaudio": True,
            "format": "bestaudio/best",
            "quiet": True,

            "outtmpl": tmpdirname + "/%(title)s.%(ext)s",
            'progress_hooks': [self.file_hook],
        }
        if self.audio_transform:
            opts.update({"postprocessors": [{"key": "FFmpegExtractAudio", "preferredcodec": audio_format, }]})
        return opts

    def connection_error(self, dl_error):
        self.retry_counter = self.retry_counter + 1
        if self.retry_counter < retry_counter_max:
            log.info("Vpn reloading...")
            # Should ONLY have this command permission (visudo)
            cmd = ["/usr/bin/sudo", "/usr/bin/systemctl", "reload", "vpn_manager.service"]
            s = subprocess.run(cmd, capture_output=True, text=True)
            if s.returncode != 0:
                raise Exception(s.stderr)
            if s.stdout:
                log.warning(s.stdout)
            sleep(post_vpn_cooldown)
            log.debug("Vpn reloaded")
        else:
            raise dl_error

    def dl_list(self, audio_data, ydl_opts):
        with youtube_dl.YoutubeDL(ydl_opts) as ydl:
            ydl.download([audio_data.pid])

    def extract_info(self):
        with youtube_dl.YoutubeDL({"quiet": True}) as ydl:
            return ydl.extract_info(self.playlist_id, download=False)

    def tag_and_copy(self, audio_data, tmpdirname):
        dest_path = path.join(self.playlist_path_location, audio_data.filename)
        filepath = path.join(tmpdirname, audio_data.filename)

        # if artist -> use id3 tags
        if audio_data.artist:
            try:
                meta = EasyID3(filepath)
            except mutagen.id3.ID3NoHeaderError:
                meta = mutagen.File(filepath, easy=True)
                meta["title"] = audio_data.tagtitle
                meta["artist"] = audio_data.artist
                meta.save()
        # copy audio file (no need to remove files in tmpdir)
        if not path.exists(dest_path):
            log.debug(f'Moving {filepath} -> {dest_path}')
            shutil.copyfile(filepath, dest_path)

    def downloader(self):
        # Dl infos only
        try:
            infos = self.extract_info()
        except youtube_dl.utils.DownloadError as dl_error:
            self.connection_error(dl_error)
            return

        playlist_title = infos["title"]
        file_list_path = path.join(self.playlist_path_location, playlist_title + ".cvs")

        # Check existing
        audio_data_list = []

        for info in infos["entries"]:
            audio_data_list.append(Audio_data(info["title"], info["id"]))

        existing_title_list = self.get_title_list(file_list_path)

        audio_data_list = list(
            filter(lambda a: a.title not in existing_title_list,
                   audio_data_list))

        # Dl and tag
        if audio_data_list:
            try:
                done_list = existing_title_list if existing_title_list else []
                for audio_data in audio_data_list:
                    # new tmp dir every dl
                    with TemporaryDirectory(dir=self.tmp_dir) as tmpdirname:
                        log.debug("Downloading: " + audio_data.title)
                        self.dl_list(audio_data, self.gen_ydl_options(tmpdirname))
                        audio_data.filename = self.last_dl_file
                        self.tag_and_copy(audio_data, tmpdirname)
                        done_list.append(audio_data.title)
                        self.write_title_list(file_list_path, done_list)
                        log.info("Downloaded: " + audio_data.title)
                        # sleep if not last occurence
                        if audio_data != audio_data_list[-1]:
                            sleep(post_dl_cooldown + randint(0, post_dl_cooldown))

            except youtube_dl.utils.DownloadError as dl_error:
                self.connection_error(dl_error)
                return

    def set_params(self, params):
        self.tmp_dir = params[0]
        self.playlist_path_location = params[1]
        self.playlist_id = params[2]
        if params[3].lower() == 'true':
            self.audio_transform = True
        elif params[3].lower() == 'false':
            self.audio_transform = False

    def run(self):
        log.debug("YDL Starting...")
        seed()
        while (self.loop):
            for params in self.params_list:
                self.set_params(params)
                self.downloader()
            sleep(loop_cooldown + randint(0, loop_cooldown))


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
