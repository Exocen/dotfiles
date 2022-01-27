from datetime import date
import mutagen
import youtube_dl
import re
import os.path
import sys

t = "PLAecd6qz5DFlaOXEmNifThzG-8mOSyyKU"
filename = None

year = date.today().strftime('%Y')


def convert(filename):
    if filename is not None:
        filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), filename)
        x = re.findall('(.*?)\s*-\s*(.*?)\..*', filename)
        if len(x[0]) == 2:
            x = x[0]
            try:
                meta = mutagen.easyid3.EasyID3(filepath)
            except mutagen.id3.ID3NoHeaderError:
                meta = mutagen.File(filepath, easy=True)
            meta['title'] = x[1]
            meta['artist'] = x[0]
            meta.save()


def my_hook(d):
    if d['status'] == 'finished':
        global filename
        filename = os.path.splitext(d['filename'])[0]+'.flac'


ydl_opts = {
    'metafromtitle': '%(artist)s - %(title)',
    'extractaudio': True,
    'format': 'bestaudio/best',
    'postprocessors': [{
        'key': 'FFmpegExtractAudio',
        'preferredcodec': 'flac',
    }],
    'outtmpl': '%(title)s.%(ext)s',
    'progress_hooks': [my_hook],
}

with youtube_dl.YoutubeDL(ydl_opts) as ydl:
    result = ydl.extract_info(t, download=False)
    for k in result['entries']:
        print(k['id'])

    with youtube_dl.YoutubeDL(ydl_opts) as ydl2:
        print(ydl.extract_info(result['entries'][0]['id'], download=False)['title'])

# with youtube_dl.YoutubeDL(ydl_opts) as ydl:
#     ydl.download([t])

# convert(filename)
