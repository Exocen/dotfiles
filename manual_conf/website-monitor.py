from selenium.webdriver.firefox.options import Options as FirefoxOptions
import hashlib
from PIL import Image
import io
from selenium.webdriver.support.select import Select
from selenium import webdriver
import time
import os.path

def sha256sum(filename):
    h  = hashlib.sha256()
    b  = bytearray(128*1024)
    mv = memoryview(b)
    with open(filename, 'rb', buffering=0) as f:
        for n in iter(lambda : f.readinto(mv), 0):
            h.update(mv[:n])
    return h.hexdigest()

def full_screenshot(driver, save_path):
    # initiate value
    save_path = save_path + '.png' if save_path[-4::] != '.png' else save_path
    img_li = []  # to store image fragment
    offset = 0  # where to start

    # js to get height
    height = driver.execute_script('return Math.max('
                                   'document.documentElement.clientHeight, window.innerHeight);')

    # js to get the maximum scroll height
    # Ref--> https://stackoverflow.com/questions/17688595/finding-the-maximum-scroll-position-of-a-page
    max_window_height = driver.execute_script('return Math.max('
                                              'document.body.scrollHeight, '
                                              'document.body.offsetHeight, '
                                              'document.documentElement.clientHeight, '
                                              'document.documentElement.scrollHeight, '
                                              'document.documentElement.offsetHeight);')

    # looping from top to bottom, append to img list
    # Ref--> https://gist.github.com/fabtho/13e4a2e7cfbfde671b8fa81bbe9359fb
    while offset < max_window_height:

        # Scroll to height
        driver.execute_script(f'window.scrollTo(0, {offset});')
        img = Image.open(io.BytesIO((driver.get_screenshot_as_png())))
        img_li.append(img)
        offset += height

    # Stitch image into one
    # Set up the full screen frame
    img_frame_height = sum([img_frag.size[1] for img_frag in img_li])
    img_frame = Image.new('RGB', (img_li[0].size[0], img_frame_height))
    offset = 0
    for img_frag in img_li:
        img_frame.paste(img_frag, (0, offset))
        offset += img_frag.size[1]
    img_frame.save(save_path)
    return img_frame

options = FirefoxOptions()
options.add_argument("--headless")
options.add_argument("--disable-gpu")

driver = webdriver.Firefox(options=options)
driver.get("https://reservation.pc.gc.ca/Jasper?List")
driver.get('https://reservation.pc.gc.ca/Jasper/BackcountryCampsites/SkylineTrail?List')
buttonList = driver.find_elements_by_tag_name('button')
for but in buttonList:
    if but.text == "OK":
        but.click()
Select(driver.find_element_by_id('selResType')).select_by_visible_text('Backcountry Camping')
month_arrival = Select(driver.find_element_by_id('selArrMth'))
month_arrival.select_by_visible_text('Aug')
driver.find_element_by_id('MainContentPlaceHolder_ListLink').click()
Select(driver.find_element_by_id('selArrDay')).select_by_visible_text("9th")
Select(driver.find_element_by_id('selPartySize')).select_by_visible_text("1")
# Select(driver.find_element_by_id('selTentPads')).select_by_visible_text("1")

#TODO selenium wait
print('Sleep')
time.sleep(2)
#todo not save the file
if not os.path.isfile('screenshot.png'):
    img = full_screenshot(driver, 'screenshot.png')

img = full_screenshot(driver, '/tmp/screenshot.png')
new_hash = sha256sum('/tmp/screenshot.png')
ori_hash = sha256sum('screenshot.png')
if new_hash == ori_hash:
    print('equals :)')
else:
    print('ERRRROROROROROOR')

driver.close()
