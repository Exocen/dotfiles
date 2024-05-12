import xml.etree.ElementTree as ET
import time
from datetime import datetime
import os


class Main:
    # arg or hostname ?
    domain = ""
    LOOP_INTERVAL = "30min"
    OFFLINE_DELAY = "2h"
    SAMPLE_RSS = '<?xml version="1.0" encoding="UTF-8"?><rss version="2.0"><channel type="online-status"><title>Status/</title><link>https://[DOMAIN]</link></channel></rss>'
    RSS_PATH = "/docker-data/nginx/status/rss.xml"
    last_rss_update = None
    channel_tree = None
    rss_tree = None

    try:
        last_rss_update = time.ctime(os.path.getmtime(RSS_PATH))
        rss_tree = ET.parse("filepath")
        channel_tree = rss_tree.getroot().find("./channel/[@type='online-status']")
    except Exception:
        rss_tree = ET.fromstring(SAMPLE_RSS.replace("[DOMAIN]", domain))
        channel_tree = rss_tree.getroot().find("./channel/[@type='online-status']")

    # save fct
    # if find item
    #   if new status
    #       item link update (link#status)
    #       item description update
    #       item pubDate update
    #   else
    #       item pubDate update
    # else create new item
    # channel_tree.append(item)

    item = ET.Element("item")
    title = ET.Element("title")
    title.text = domain
    item.append(title)
    link = ET.Element("link")
    link.text = "status." + domain
    item.append(link)
    description = ET.Element("description")
    description.text = "online"
    item.append(description)
    pubDate = ET.Element("pubDate")
    pubDate.text = int(time.mktime((datetime.now().timetuple())))
    item.append(pubDate)

    channel_tree.append(item)

    # check loop fct
    # while true + sleep LOOP_INTERVAL
    # if last_rss_update != time.ctime(os.path.getmtime(RSS_PATH))
    #   read all
    #   if description == online and pubDate + OFFLINE_DELAY < datetime.now()
    #       description update to offline
    #       link update (link#status)
    # last_rss_update = time.ctime(os.path.getmtime(RSS_PATH))

    # main fct
    # args save or loop


if __name__ == "__main__":
    Main().run()
