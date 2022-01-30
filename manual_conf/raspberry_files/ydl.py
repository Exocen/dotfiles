import re
import sys
import csv
import shutil
import youtube_dl
import mutagen
from mutagen.easyid3 import EasyID3
from os import path, environ, listdir
from tempfile import mkdtemp

# Usage ./Script dest-dir pid

audio_format = "flac"
# User tmp
tmp_dir = path.normpath(environ.get("XDG_RUNTIME_DIR"))
# Should be removed before successfull script end
pytemp_dir = mkdtemp(dir=tmp_dir)
playlist_id = sys.argv[-1]
playlist_path_location = sys.argv[-2]

# TODO ADD options rng + sleep + stuff

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
    "keepvideo": True,
}


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
        self.filepath = path.join(pytemp_dir, self.filename)


def dl_list(audio_data_list):
    with youtube_dl.YoutubeDL(ydl_opts) as ydl:
        ydl.download([audio_data.pid for audio_data in audio_data_list])


def extract_info():
    with youtube_dl.YoutubeDL() as ydl:
        return ydl.extract_info(playlist_id, download=False)


def tag_and_copy(audio_data_list):
    for audio_data in audio_data_list:
        if audio_data.filepath:
            dest_path = path.join(playlist_path_location, audio_data.filename)
            if audio_data.artist:
                try:
                    meta = EasyID3(audio_data.filepath)
                except mutagen.id3.ID3NoHeaderError:
                    meta = mutagen.File(audio_data.filepath, easy=True)
                    meta["title"] = audio_data.title
                    meta["artist"] = audio_data.artist
                    meta.save()
            if not path.exists(dest_path):
                shutil.copyfile(audio_data.filepath, dest_path)


def generate_file_list(file_path):
    if path.exists(file_path):
        with open(file_path, newline="") as f:
            reader = csv.reader(f)
            return list(reader)[0]
    else:
        return listdir(playlist_path_location)


def write_title_list(file_path):
    existing_title_list = listdir(playlist_path_location)
    print(existing_title_list)
    with open(file_path, "w", newline="") as csv_file:
        write = csv.writer(csv_file)
        write.writerow(existing_title_list)


def main():

    # Dl infos only
    infos = extract_info()
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

    # Dl and tag missing
    if audio_data_list:
        dl_list(audio_data_list)
        tag_and_copy(audio_data_list)

    # Create fast save
    write_title_list(file_list_path)

    shutil.rmtree(pytemp_dir)


if __name__ == "__main__":
    sys.exit(main())
