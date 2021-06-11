from selenium.webdriver.firefox.options import Options as FirefoxOptions
import hashlib
from PIL import Image
import io
from selenium.webdriver.support.select import Select
from selenium import webdriver
import time
import os.path


def full_screenshot(driver):
    img_li = []  # to store image fragment
    offset = 0  # where to start
    # js to get height
    height = driver.execute_script('return Math.max('
                                   'document.documentElement.clientHeight, window.innerHeight);')

    # js to get the maximum scroll height
    max_window_height = driver.execute_script('return Math.max('
                                              'document.body.scrollHeight, '
                                              'document.body.offsetHeight, '
                                              'document.documentElement.clientHeight, '
                                              'document.documentElement.scrollHeight, '
                                              'document.documentElement.offsetHeight);')

    # looping from top to bottom, append to img list
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
    # img_frame.save(save_path)
    # return hashlib.sha256(img_frame.tobytes()).hexdigest()
    return img_frame


def init():
    options = FirefoxOptions()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    return webdriver.Firefox(options=options)


def check_reserv(driver):
    address = 'https://reservation.pc.gc.ca/Jasper/BackcountryCampsites/SkylineTrail?List'
    driver.get(address)
    driver.get(address)

    # bullshit popup
    buttonList = driver.find_elements_by_tag_name('button')
    for but in buttonList:
        if but.text == "OK":
            but.click()

    # Select
    Select(driver.find_element_by_id('selResType')
           ).select_by_visible_text('Backcountry Camping')
    Select(driver.find_element_by_id('selArrMth')
           ).select_by_visible_text('Aug')
    driver.find_element_by_id('MainContentPlaceHolder_ListLink').click()
    Select(driver.find_element_by_id('selArrDay')
           ).select_by_visible_text("9th")
    Select(driver.find_element_by_id('selPartySize')
           ).select_by_visible_text("1")
    Select(driver.find_element_by_id('selTentPads')
           ).select_by_visible_text("1")

    # TODO selenium wait
    print('Sleep')
    time.sleep(2)

    if not os.path.isfile('screenshot.png'):
        full_screenshot(driver).save('screenshot.png')

    with Image.open('screenshot.png') as img:
        new_img = full_screenshot(driver)
        new_hash = hashlib.sha256(new_img.tobytes()).hexdigest()
        ori_hash = hashlib.sha256(img.tobytes()).hexdigest()

        if new_hash == ori_hash:
            print('equals :)')
        else:
            print('ERRRROROROROROOR')


driver = init()
check_reserv(driver)
driver.quit()
