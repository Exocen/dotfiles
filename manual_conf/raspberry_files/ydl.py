import mutagen
import youtube_dl
import re
import sys
from os import path, environ

playlist_id = sys.args[0] if len(sys.argv) == 1 else None
audio_format = "flac"

# create and delete this
temp_dest = '/run/user/' + environ['UID'] + '/'

filepath_by_id = dict()

def my_hook(v):
    if v['status'] == 'finished':
        # global filepath_by_id
        filepath_by_id[v['id']] = v['FILELELELELELANME']
        # find and select audiodata , then add filepath :

ydl_opts = {
    'extractaudio': True,
    'format': 'bestaudio/best',
    'postprocessors': [{
        'key': 'FFmpegExtractAudio',
        'preferredcodec': audio_format,
    }],
    'progress_hooks': [my_hook],
}

class audio_data:
    artist = ''
    filepath = ''

    def __init__(self, title, yid):
        self.title = title
        self.yid = yid
        parsed_title = re.findall(r'(.*?)\s*-\s*(.*?)\..*', title)
        if len(parsed_title) > 0 and len(parsed_title[0]) == 2:
            self.artist = parsed_title[0][0]
            self.title = parsed_title[0][1]

    def get_filename(self):
        if not self.artist:
            return self.title + '.' + audio_format
        return self.artist + ' - ' + self.title + '.' + audio_format


# dl all one with
def dl_list():
    # with youtube_dl.YoutubeDL(ydl_opts) as ydl:
    #     ydl.download([t])
    # getfilepath
    pass


def tag_and_move(audio_data, playlist_name):

    if audio_data.filepath:
        if audio_data.artist:
            filepath = path.join(path.dirname(path.abspath(__file__)), 'wdqqwd')
            try:
                meta = mutagen.easyid3.EasyID3(filepath)
            except mutagen.id3.ID3NoHeaderError:
                meta = mutagen.File(filepath, easy=True)
                meta['title'] = audio_data.title
                meta['artist'] = audio_data.artist
                meta.save()
        # move file BUT NOT OVERWRITE
        # move dest -> music playlist -> playlist name
    # return succeded title_list[]

def generate_file_list(file_path):
    # if exist : load and return []
    # else : read dir and return []
    pass

def __main__():
    # infos = extract_info()
    # playlist title -> title_list.cvs -> temp_dest
    # file_list_path = path.join(temp_dest, 'title_list'+'.cvs')
    # audio_data_list = []
    # for info in infos['entries']:
    #   audio_data_list.append(audio_data(info['title'],info['id']))
    # existing_title_list = generate_file_list(file_list_path)
    # audio_data_list = filter(lambda a: a.title not in existing_title_list,audio_data_list)
    # if audio_data_list:
    #   download
    #   for audio_data in audio_data_list:
    #       audio_data.file_path = filepath_by_id[audio_data.yid]
    #   existing_title_list = tag_and_move(audio_data_list)
    # create/overwrite file_list_path with existing_title_list
    pass

with youtube_dl.YoutubeDL() as ydl:
    result = ydl.extract_info(playlist_id, download=False)
    for k in result['entries']:
        print(k['id'])

    with youtube_dl.YoutubeDL(ydl_opts) as ydl2:
        print(ydl.extract_info(result['entries'][0]['id'], download=False)['title'])
