from selenium.webdriver.firefox.options import Options as FirefoxOptions
import hashlib
from PIL import Image
import io
import subprocess
from selenium.webdriver.support.select import Select
from selenium import webdriver
import time
import os.path
import requests


def full_screenshot(driver):
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


def init():
    options = FirefoxOptions()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    return webdriver.Firefox(options=options)


def check_reserv(driver):
    img_path = "screenshot.png"
    address = "https://reservation.pc.gc.ca/Jasper/BackcountryCampsites/SkylineTrail?List"
    driver.get(address)
    driver.get(address)

    # bullshit popup
    buttonList = driver.find_elements_by_tag_name("button")
    for but in buttonList:
        if but.text == "OK":
            but.click()

    # Select
    Select(driver.find_element_by_id("selResType")).select_by_visible_text(
        "Backcountry Camping"
    )
    Select(driver.find_element_by_id("selArrMth")
           ).select_by_visible_text("Aug")
    driver.find_element_by_id("MainContentPlaceHolder_ListLink").click()
    # TODO wait
    time.sleep(1)
    Select(driver.find_element_by_id("selArrDay")
           ).select_by_visible_text("9th")
    Select(driver.find_element_by_id("selPartySize")
           ).select_by_visible_text("1")
    Select(driver.find_element_by_id("selTentPads")
           ).select_by_visible_text("1")

    # TODO selenium wait
    time.sleep(1)

    if not os.path.isfile(img_path):
        full_screenshot(driver).save(img_path)

    with Image.open(img_path) as img:
        new_img = full_screenshot(driver)
        new_hash = hashlib.sha256(new_img.tobytes()).hexdigest()
        ori_hash = hashlib.sha256(img.tobytes()).hexdigest()

        if new_hash != ori_hash:
            bash_scp = "scp "+img_path+" exocen.com:/tmp/"
            subprocess.run(bash_scp, shell=True, check=True,
                           executable="/bin/bash")
            message = "Website update"
            bash2 = "sendemail -m '"+message + \
                "' -t exo@exocen.com -u 'TRAIL CAMP UPDATE' -f check@exocen.com -a /tmp/"+img_path+""
            bashCommand = 'ssh exocen.com "' + bash2 + '"'
            subprocess.run(bashCommand, shell=True,
                           check=True, executable="/bin/bash")
            new_img.save(img_path)


def check_smbc(driver):

    def contentToFile(content, file):
        file = open(img_path, "wb")
        file.write(response.content)
        file.close()
        
    img_path = "smbc_screenshot.png"
    address = "https://www.smbc-comics.com/"
    driver.get(address)

    img_url = driver.find_element_by_id("cc-comic").get_attribute('src')

    response = requests.get(img_url)

    # TODO selenium wait
    time.sleep(1)

    if not os.path.isfile(img_path):
        contentToFile(response.content, img_path)

    with Image.open(img_path) as img:
        new_img = Image.open(io.BytesIO(response.content))
        new_hash = hashlib.sha256(new_img.tobytes()).hexdigest()
        ori_hash = hashlib.sha256(img.tobytes()).hexdigest()

        if new_hash != ori_hash:
            bash_scp = "scp "+img_path+" exocen.com:/tmp/"
            subprocess.run(bash_scp, shell=True, check=True,
                           executable="/bin/bash")
            message = "Website update"
            bash2 = "sendemail -m '"+message + \
                "' -t exo@exocen.com -u 'smbc UPDATE' -f exo2@exocen.com -a /tmp/"+img_path+""
            bashCommand = 'ssh exocen.com "' + bash2 + '"'
            subprocess.run(bashCommand, shell=True,
                           check=True, executable="/bin/bash")
            contentToFile(response.content, img_path)



try:
    driver = init()
    check_reserv(driver)
    check_smbc(driver)
except Exception as e:
    print(e)
finally:
    driver.quit()
