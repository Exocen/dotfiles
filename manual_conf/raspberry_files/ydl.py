from datetime import date
import mutagen
import youtube_dl
import re
import os.path
import sys

t = "PLAecd6qz5DFlaOXEmNifThzG-8mOSyyKU"
audio_format = "flac"
audio_data_list = []

#create and delete this
temp_dest = '~/tmp_files'

year = date.today().strftime('%Y')

ydl_opts = {
    # 'metafromtitle': '%(artist)s - %(title)',
    'extractaudio': True,
    'format': 'bestaudio/best',
    'postprocessors': [{
        'key': 'FFmpegExtractAudio',
        'preferredcodec': audio_format,
    }],
    # 'outtmpl': '%(title)s.%(ext)s',
    # 'progress_hooks': [my_hook],
}
# todo rem outtmpl and metafromtile

class audio_data:
    artist = ''
    filepath = ''

    def __init__(self, title, yid):
        self.title = title
        self.yid = yid
        parsed_title = re.findall('(.*?)\s*-\s*(.*?)\..*', title)
        if len(parsed_title) > 0 and len(parsed_title[0]) == 2:
            self.artist = parsed_title[0][0]
            self.title = parsed_title[0][1]

    def get_filename(self):
        if not self.artist:
            return self.title + '.' + audio_format
        return self.artist + ' - ' + self.title + '.' + audio_format


#dl all one with
def dl_list(audio_datas):
    # getfilepath
    pass


def tag_and_move(audio_data):

    if audio_data.filepath:
        if audio_data.artist:
            filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), filename)
            try:
               meta = mutagen.easyid3.EasyID3(filepath)
            except mutagen.id3.ID3NoHeaderError:
                meta = mutagen.File(filepath, easy=True)
                meta['title'] = audio_data.title
                meta['artist'] = audio_data.artist
                meta.save()
        #move file BUT NOT OVERWRITE


def sort_stuff(title):
    # full dict_title_by_id
    # for filename in dict_title_by_audio:
    # compare get_filename with existing files or csv list
    # take the rest and compare with
    # dict_title_by_audio.pop(title, None)
    pass


def my_hook(d):
    if d['status'] == 'finished':
        # find and select audiodata , then add filepath :
        filename.append(os.path.splitext(d['filename'])[0]+'.'+audio_format)


with youtube_dl.YoutubeDL(ydl_opts) as ydl:
    result = ydl.extract_info(t, download=False)
    for k in result['entries']:
        print(k['id'])

    with youtube_dl.YoutubeDL(ydl_opts) as ydl2:
        print(ydl.extract_info(result['entries'][0]['id'], download=False)['title'])

# with youtube_dl.YoutubeDL(ydl_opts) as ydl:
#     ydl.download([t])

# convert(filename)
