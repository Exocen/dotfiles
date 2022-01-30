import mutagen
from mutagen.easyid3 import EasyID3
import youtube_dl
import re
import sys
from os import path, environ, listdir
import csv
import shutil
from tempfile import mkdtemp

# Usage ./Script dest-dir yid

audio_format = "flac"
# User tmp
tmp_dir = path.normpath(environ.get("XDG_RUNTIME_DIR"))
# Should be removed before script end
pytemp_dir = mkdtemp(dir=tmp_dir)
filepath_by_title = dict()


def my_hook(v):
    if v["status"] == "finished":
        print("hook: " + v["filename"])
        filepath_by_title[path.basename(v["filename"])] = v["filename"]


ydl_opts = {
    "extractaudio": True,
    "format": "bestaudio/best",
    "postprocessors": [
        {
            "key": "FFmpegExtractAudio",
            "preferredcodec": audio_format,
        }
    ],
    "outtmpl": pytemp_dir + "/%(title)s.%(ext)s",
    "progress_hooks": [my_hook],
    "keepvideo": True,
}


class Audio_data:
    artist = ""

    def __init__(self, title, yid):
        self.title = title
        self.yid = yid
        parsed_title = re.findall(r"(.*?)\s*-\s*(.*)", title)
        if len(parsed_title) > 0 and len(parsed_title[0]) == 2:
            self.artist = parsed_title[0][0]
            self.title = parsed_title[0][1]

    @property
    def filename(self):
        if not self.artist:
            return self.title + "." + audio_format
        return self.artist + " - " + self.title + "." + audio_format

    @property
    # Src Filepath
    def filepath(self):
        return path.join(pytemp_dir, self.filename)


def dl_list(audio_data_list):
    with youtube_dl.YoutubeDL(ydl_opts) as ydl:
        ydl.download([audio_data.yid for audio_data in audio_data_list])


def extract_info(playlist_id):
    with youtube_dl.YoutubeDL() as ydl:
        return ydl.extract_info(playlist_id, download=False)


def tag_and_move(audio_data_list, playlist_path_location):
    for audio_data in audio_data_list:
        if audio_data.filepath:
            if audio_data.artist:
                dest_path = path.join(playlist_path_location, audio_data.filename)
                try:
                    meta = EasyID3(audio_data.filepath)
                except mutagen.id3.ID3NoHeaderError:
                    meta = mutagen.File(audio_data.filepath, easy=True)
                    meta["title"] = audio_data.title
                    meta["artist"] = audio_data.artist
                    meta.save()
                if not path.exists(dest_path):
                    shutil.copyfile(audio_data.filepath, dest_path)


def generate_file_list(file_path, playlist_path_location):
    if path.exists(file_path):
        with open(file_path, newline="") as f:
            reader = csv.reader(f)
            return list(reader)[0]
    else:
        return listdir(playlist_path_location)


def write_title_list(file_path, playlist_path_location):
    existing_title_list = listdir(playlist_path_location)
    print(existing_title_list)
    with open(file_path, "w", newline="") as csv_file:
        write = csv.writer(csv_file)
        write.writerow(existing_title_list)


def main():
    playlist_id = sys.argv[-1]
    playlist_path_location = sys.argv[-2]

    # Dl infos only
    infos = extract_info(playlist_id)
    playlist_title = infos["title"]
    file_list_path = path.join(tmp_dir, playlist_title + ".cvs")

    # Check existing
    audio_data_list = []
    for info in infos["entries"]:
        audio_data_list.append(Audio_data(info["title"], info["id"]))

    existing_title_list = generate_file_list(file_list_path, playlist_path_location)

    audio_data_list = list(
        filter(lambda a: a.filename not in existing_title_list, audio_data_list)
    )

    # Dl and tag missing
    if audio_data_list:
        dl_list(audio_data_list)
        tag_and_move(audio_data_list, playlist_path_location)

    # Create fast save
    write_title_list(file_list_path, playlist_path_location)

    shutil.rmtree(pytemp_dir)


if __name__ == "__main__":
    sys.exit(main())
