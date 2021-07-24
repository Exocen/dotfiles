# pip install selenium

import hashlib
import io
import multiprocessing as mp
import os
import subprocess
from datetime import datetime

import requests
from PIL import Image
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.select import Select
from selenium.webdriver.support.ui import WebDriverWait

file_path = os.path.dirname(os.path.realpath(__file__))
debug = True
domain = '@exocen.com'
bcc = 'check' + domain
chaton = 'chaton' + domain
frm = 'exo' + domain
wsh = 'wesh' + domain
scp_command = "scp {} " + frm + ":/tmp/"
send_mail_command = "sendemail -m ' ' -t {0} -bcc " + \
        bcc + " -u 'Trail update' -f " + frm + " -a '/tmp/{1}'"
ssh_command = 'ssh ' + frm + ' "{}"'

# TODO les conventions putain ....
# TODO add debug logs + debug run (--dry-run)
# TODO add args


def run_process(command):
    if not debug:
        subprocess.run(command, shell=True, check=True, executable="/bin/bash")


def backup_file(file_path):
    new_name = str(int(datetime.today().timestamp()))
    file_path_wo_ext, ext = os.path.splitext(file_path)
    new_path = file_path_wo_ext + '-' + new_name + ext
    os.rename(file_path, new_path)


def init():
    options = Options()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("start-maximized"); # open Browser in maximized mode
    options.add_argument("disable-infobars"); #// disabling infobars
    options.add_argument("--disable-extensions"); #// disabling extensions
    options.add_argument("--disable-dev-shm-usage"); #// overcome limited resource problems
    return webdriver.Chrome(options=options, service_log_path=os.path.devnull)


def hike_set_select_with_elemend_id(wait, id, text):
    wel = wait.until(EC.presence_of_element_located((By.ID, id)))
    Select(wel).select_by_visible_text(text)
    wait.until(EC.invisibility_of_element((By.ID, 'viewPortStatus')))


def check_reserv(driver):
    img_filename = "skyline_screenshot.png"
    img_path = os.path.join(file_path, img_filename)
    address = "https://reservation.pc.gc.ca/Jasper/BackcountryCampsites/SkylineTrail?List"
    driver.get(address)
    print('get')

    # bullshit popup
    buttonList = driver.find_elements_by_tag_name("button")
    for but in buttonList:
        if but.text == "OK":
            but.click()
    print('wait')
    wait = WebDriverWait(driver, 10)

    hike_set_select_with_elemend_id(wait, 'selResType', 'Backcountry Camping')

    driver.get(address)
    wait.until(EC.invisibility_of_element((By.ID, 'viewPortStatus')))

    hike_set_select_with_elemend_id(wait, 'selArrMth', 'Aug')
    hike_set_select_with_elemend_id(wait, 'selArrDay', '29th')

    hike_set_select_with_elemend_id(wait, 'selPartySize', '1')
    hike_set_select_with_elemend_id(wait, 'selTentPads', '1')

    if not os.path.isfile(img_path):
        driver.find_element_by_id('viewPort').screenshot(img_path)

    print('img')
    with Image.open(img_path) as img:

        new_img = Image.open(io.BytesIO(
            driver.find_element_by_id('viewPort').screenshot_as_png))
        new_hash = hashlib.sha256(new_img.tobytes()).hexdigest()
        ori_hash = hashlib.sha256(img.tobytes()).hexdigest()
    print('compare')
    if new_hash != ori_hash:
        backup_file(img_path)
        new_img.save(img_path)
        bash_scp = scp_command.format(img_path)
        run_process(bash_scp)
        bash2 = send_mail_command.format(chaton, img_filename)
        bashCommand = ssh_command.format(bash2)
        run_process(bashCommand)
        return 'Skyline New File'
    else:
        return 'Skyline No changes'


def check_reserv2(driver):
    img_filename = "malign_screenshot.png"
    img_path = os.path.join(file_path, img_filename)
    address = "https://reservation.pc.gc.ca/Jasper/BackcountryCampsites/MalignePassTrail?List"
    driver.get(address)

    # bullshit popup
    buttonList = driver.find_elements_by_tag_name("button")
    for but in buttonList:
        if but.text == "OK":
            but.click()

    wait = WebDriverWait(driver, 10)

    hike_set_select_with_elemend_id(wait, 'selResType', 'Backcountry Camping')

    driver.get(address)
    wait.until(EC.invisibility_of_element((By.ID, 'viewPortStatus')))

    hike_set_select_with_elemend_id(wait, 'selArrMth', 'Sep')
    hike_set_select_with_elemend_id(wait, 'selArrDay', '1st')

    hike_set_select_with_elemend_id(wait, 'selPartySize', '1')
    hike_set_select_with_elemend_id(wait, 'selTentPads', '1')

    if not os.path.isfile(img_path):
        driver.find_element_by_id('viewPort').screenshot(img_path)

    with Image.open(img_path) as img:

        new_img = Image.open(io.BytesIO(
            driver.find_element_by_id('viewPort').screenshot_as_png))
        new_hash = hashlib.sha256(new_img.tobytes()).hexdigest()
        ori_hash = hashlib.sha256(img.tobytes()).hexdigest()

    if new_hash != ori_hash:
        backup_file(img_path)
        new_img.save(img_path)
        bash_scp = scp_command.format(img_path)
        run_process(bash_scp)
        bash2 = send_mail_command.format(chaton, img_filename)
        bashCommand = ssh_command.format(bash2)
        run_process(bashCommand)
        return 'Maligne New File'
    else:
        return 'Maligne No changes'

def run_check(check):
    log = ''
    try:
        driver = init()
        log = check(driver)
    except Exception:
        raise
    finally:
        driver.quit()
    return log


begin_time = datetime.now()
lame_log = []
run_check(check_reserv)
# to_run = [check_reserv]
# try:
#     pool = mp.Pool(mp.cpu_count())
#     lame_log += pool.map(run_check, [check for check in to_run])
# except:
#     raise
# finally:
#     pool.close()

execution_time = str(datetime.now() - begin_time)

print(', '.join(lame_log) + ' | ' + execution_time)
