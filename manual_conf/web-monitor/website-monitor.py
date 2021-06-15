import hashlib
import io
import os
import subprocess
from datetime import datetime

import requests
from PIL import Image
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.select import Select
from selenium.webdriver.support.ui import WebDriverWait

file_path = os.path.dirname(os.path.realpath(__file__))
# TODO add timestamp + logs


def full_screenshot(driver):
    driver.implicitly_wait(2)
    img_li = []  # to store image fragment
    offset = 0  # where to start
    # js to get height
    height = driver.execute_script(
        "return Math.max(" "document.documentElement.clientHeight, window.innerHeight);"
    )

    # js to get the maximum scroll height
    max_window_height = driver.execute_script(
        "return Math.max("
        "document.body.scrollHeight, "
        "document.body.offsetHeight, "
        "document.documentElement.clientHeight, "
        "document.documentElement.scrollHeight, "
        "document.documentElement.offsetHeight);"
    )

    # looping from top to bottom, append to img list
    while offset < max_window_height:
        # Scroll to height
        driver.execute_script(f"window.scrollTo(0, {offset});")
        img = Image.open(io.BytesIO((driver.get_screenshot_as_png())))
        img_li.append(img)
        offset += height
    # Stitch image into one
    # Set up the full screen frame
    img_frame_height = sum([img_frag.size[1] for img_frag in img_li])
    img_frame = Image.new("RGB", (img_li[0].size[0], img_frame_height))
    offset = 0
    for img_frag in img_li:
        img_frame.paste(img_frag, (0, offset))
        offset += img_frag.size[1]
    # img_frame.save(save_path)
    # return hashlib.sha256(img_frame.tobytes()).hexdigest()
    return img_frame


def backup_file(file_path):
    new_name = str(int(datetime.today().timestamp()))
    file_path_wo_ext, ext = os.path.splitext(file_path)
    new_path = file_path_wo_ext + '-' + new_name + ext
    os.rename(file_path, new_path)


def init():
    options = FirefoxOptions()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    return webdriver.Firefox(options=options)


def set_select_with_elemend_id(wait, id, text):
    wel = wait.until(EC.presence_of_element_located((By.ID, id)))
    Select(wel).select_by_visible_text(text)
    wait.until(EC.invisibility_of_element((By.ID, 'viewPortStatus')))


def check_reserv(driver):
    img_filename = "screenshot.png"
    img_path = os.path.join(file_path, img_filename)
    address = "https://reservation.pc.gc.ca/Jasper/BackcountryCampsites/SkylineTrail?List"
    driver.get(address)

    # bullshit popup
    buttonList = driver.find_elements_by_tag_name("button")
    for but in buttonList:
        if but.text == "OK":
            but.click()

    wait = WebDriverWait(driver, 10)

    set_select_with_elemend_id(wait, 'selResType', 'Backcountry Camping')

    driver.get(address)
    wait.until(EC.invisibility_of_element((By.ID, 'viewPortStatus')))

    set_select_with_elemend_id(wait, 'selArrMth', 'Aug')
    set_select_with_elemend_id(wait, 'selArrDay', '29th')

    set_select_with_elemend_id(wait, 'selPartySize', '1')
    set_select_with_elemend_id(wait, 'selTentPads', '1')

    if not os.path.isfile(img_path):
        full_screenshot(driver).save(img_path)

    with Image.open(img_path) as img:

        new_img = full_screenshot(driver)
        new_hash = hashlib.sha256(new_img.tobytes()).hexdigest()
        ori_hash = hashlib.sha256(img.tobytes()).hexdigest()

    if new_hash != ori_hash:
        backup_file(img_path)
        new_img.save(img_path)
        bash_scp = "scp "+img_path+" exo@exocen.com:/tmp/"
        subprocess.run(bash_scp, shell=True, check=True,
                       executable="/bin/bash")
        message = "Website update"
        bash2 = "sendemail -m '"+message + \
            "' -t chaton@exocen.com -cc check@exocen.com -u 'TRAIL CAMP UPDATE' -f exo@exocen.com -a /tmp/"+img_filename+""
        bashCommand = 'ssh exo@exocen.com "' + bash2 + '"'
        subprocess.run(bashCommand, shell=True,
                       check=True, executable="/bin/bash")
    else:
        print('Hike No changes')


def check_smbc(driver):

    def contentToFile(content, file):
        file = open(img_path, "wb")
        file.write(response.content)
        file.close()

    img_filename = "smbc_screenshot.png"
    img_path = os.path.join(file_path, img_filename)
    address = "https://www.smbc-comics.com/"
    driver.get(address)

    img_url = driver.find_element_by_id("cc-comic").get_attribute('src')

    response = requests.get(img_url)

    if not os.path.isfile(img_path):
        contentToFile(response.content, img_path)

    with Image.open(img_path) as img:
        new_img = Image.open(io.BytesIO(response.content))
        new_hash = hashlib.sha256(new_img.tobytes()).hexdigest()
        ori_hash = hashlib.sha256(img.tobytes()).hexdigest()

    if new_hash != ori_hash:
        backup_file(img_path)
        contentToFile(response.content, img_path)
        bash_scp = "scp "+img_path+" exo@exocen.com:/tmp/"
        subprocess.run(bash_scp, shell=True, check=True,
                       executable="/bin/bash")
        message = "Website update"
        bash2 = "sendemail -m '"+message + \
            "' -t wesh@exocen.com -bcc exo@exocen.com -u 'smbc UPDATE' -f exo2@exocen.com -a /tmp/"+img_filename+""
        bashCommand = 'ssh exo@exocen.com "' + bash2 + '"'
        subprocess.run(bashCommand, shell=True,
                       check=True, executable="/bin/bash")
    else:
        print('SMBC No changes')


try:
    driver = init()
    check_reserv(driver)
    check_smbc(driver)
except Exception:
    raise
finally:
    driver.quit()
