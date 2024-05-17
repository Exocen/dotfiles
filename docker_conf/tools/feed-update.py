import logging
import os
import shutil
import socket
import sys
import time
import uuid
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
from tempfile import TemporaryDirectory

TMP_DIR = "/run/"
ATOM_PATH = "/docker-data/nginx/status/atom.xml"
# Can be volatile
FEED_UPDATE_LOCATION = "/run/feed/update/"
# Must be persistent
NOTIFICATION_UPDATE_LOCATION = "/var/tmp/feed/notifications/"

LOOP_INTERVAL = 1200
OFFLINE_DELAY = timedelta(hours=1)
MAX_NOTIFICATIONS = 20
START_DELAY = 300

USAGE = "Usage: feed-update [ loop | notif | update ] \n loop -> run check loop \n notif -> add a notification (title+text) \n update -> update/add given host"
SAMPLE_ATOM = """<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>[HOST] feed</title>
  <link href="https://status.[HOST]/atom.xml" rel="self" />
  <updated>[TIME]</updated>
  <author>
    <name>[HOST]</name>
  </author>
  <id>[ID]</id>
</feed>"""
UPDATE_ENTRY = """<entry type='update'>
    <title>[HOST2]</title>
    <link href="https://status.[HOST]/#[HOST2]"/>
    <id>[ID]</id>
    <updated>""</updated>
    <summary>online</summary>
  </entry>"""
NOTIFICATION_ENTRY = """<entry type='notif'>
    <title>[TITLE]</title>
    <link href="https://status.[HOST]/#[TITLE]"/>
    <id>[ID]</id>
    <updated>[UPDATED]</updated>
    <summary>[MESSAGE]</summary>
  </entry>"""

DATE_FORMAT = "%Y-%m-%dT%H:%M:%SZ"
NS = {"": "http://www.w3.org/2005/Atom"}
LOG = logging.getLogger("YDL")


class Main:
    @staticmethod
    def genId():
        return "urn:uuid:" + str(uuid.uuid1())

    @staticmethod
    def genTime():
        return datetime.now().strftime(DATE_FORMAT)

    @staticmethod
    def findOrCreate(element, subelement_str):
        subelement = element.find("{*}" + subelement_str, NS)
        if subelement is None:
            subelement = ET.Element(subelement_str)
            element.append(subelement)
        return subelement

    @staticmethod
    def init_dirs():
        os.makedirs(FEED_UPDATE_LOCATION, exist_ok=True)
        os.makedirs(NOTIFICATION_UPDATE_LOCATION, exist_ok=True)

    def __init__(self):
        logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
        Main.init_dirs()
        self.feed_tree = None
        self.tree = None
        self.tree_updated = False
        self.host = socket.gethostname()
        self.importTree()

    def importTree(self):
        try:
            ET.register_namespace("", "http://www.w3.org/2005/Atom")
            LOG.debug(f"Retrieving {ATOM_PATH}")
            self.tree = ET.parse(ATOM_PATH)
            if self.tree is None:
                raise Exception("Feed empty")
            self.feed_tree = self.tree.getroot()
        except Exception as exception:
            LOG.debug(f"{exception}")
            LOG.warning(f"{ATOM_PATH} retrieving failed, creating new feed")
            self.tree = ET.ElementTree(
                ET.fromstring(
                    SAMPLE_ATOM.replace("[HOST]", self.host)
                    .replace("[ID]", Main.genId())
                    .replace("[TIME]", Main.genTime())
                )
            )
            self.feed_tree = self.tree.getroot()
            self.tree_updated = True

    def getUpdateList(self):
        # Return list of host to update
        LOG.debug(f"Getting files from {FEED_UPDATE_LOCATION}")
        update_list = []
        try:
            file_list = os.listdir(FEED_UPDATE_LOCATION)
            for file in file_list:
                update_list.append(file)
                os.remove(os.path.join(FEED_UPDATE_LOCATION, file))
        except Exception as read_exception:
            LOG.error(f"Error trying to read {FEED_UPDATE_LOCATION}: {read_exception}")
        return update_list

    def getNotificationList(self):
        # Return list of tuple notifications to add to the feed key=>title and value=>summary
        LOG.debug(f"Getting files from {NOTIFICATION_UPDATE_LOCATION}")
        update_list = []
        try:
            file_list = os.listdir(NOTIFICATION_UPDATE_LOCATION)
            for file in file_list:
                file_path = os.path.join(NOTIFICATION_UPDATE_LOCATION, file)
                with open(file_path, "r") as file_buf:
                    file_lines = file_buf.readlines()
                    if len(file_lines) != 2:
                        raise Exception(
                            f"{file_path} contains {len(file_lines)} line(s) (should be 2) "
                        )
                    tup = (
                        file_lines[0].replace("\n", ""),
                        file_lines[1].replace("\n", ""),
                    )
                    update_list.append(tup)
                os.remove(file_path)
        except Exception as read_exception:
            LOG.error(
                f"Error trying to read {NOTIFICATION_UPDATE_LOCATION}: {read_exception}"
            )
        return update_list

    def updateStatus(self, host):
        titles = self.feed_tree.findall('./{*}entry/{*}title[.="' + host + '"]', NS)
        if not titles:
            ET.register_namespace("", "http://www.w3.org/2005/Atom")
            entry = ET.fromstring(
                UPDATE_ENTRY.replace("[HOST]", self.host)
                .replace("[HOST2]", host)
                .replace("[ID]", Main.genId())
            )
            self.feed_tree.append(entry)

            titles = entry.findall('./{*}title[.="' + host + '"]', NS)

        for title in titles:
            parent_map = {c: p for p in self.feed_tree.iter() for c in p}
            if titles[0] == title:
                entry = parent_map[title]
                summary = Main.findOrCreate(entry, "summary")
                if summary.text == "online":
                    Main.findOrCreate(entry, "updated").text = Main.genTime()
                    Main.findOrCreate(self.feed_tree, "updated").text = Main.genTime()
                else:
                    summary.text = "online"
                    Main.findOrCreate(entry, "updated").text = Main.genTime()
                    Main.findOrCreate(self.feed_tree, "updated").text = Main.genTime()
                    Main.findOrCreate(entry, "id").text = Main.genId()
            else:
                try:
                    parent_map[title].remove(title)
                except ValueError:
                    pass
        self.tree_updated = True

    def cleanNotifs(self):
        # Remove oldest notifs if too many (MAX_NOTIFICATIONS)
        entries = self.feed_tree.findall('./{*}entry[@type="notif"]', NS)
        if len(entries) > MAX_NOTIFICATIONS:
            LOG.info("Too many notifications detected, removing oldest ones")
            parent_map = {c: p for p in self.feed_tree.iter() for c in p}
            entries_to_remove = entries[:MAX_NOTIFICATIONS]
            for entry_to_remove in entries_to_remove:
                parent_map[entry_to_remove].remove(entry_to_remove)
            self.tree_updated = True

    def updateNotifs(self, title, message):
        ET.register_namespace("", "http://www.w3.org/2005/Atom")
        entry = ET.fromstring(
            NOTIFICATION_ENTRY.replace("[HOST]", self.host)
            .replace("[HOST]", self.host)
            .replace("[TITLE]", title)
            .replace("[ID]", Main.genId())
            .replace("[MESSAGE]", message)
            .replace("[UPDATED]", Main.genTime())
        )
        self.feed_tree.append(entry)
        Main.findOrCreate(self.feed_tree, "updated").text = Main.genTime()
        self.tree_updated = True

    def checkExpiredEntries(self):
        # Check online entries if no new update for too long -> offline
        entries = self.feed_tree.findall('./{*}entry[@type="update"]', NS)
        for entry in entries:
            summary = Main.findOrCreate(entry, "summary")
            if summary.text == "online":
                updated = Main.findOrCreate(entry, "updated")
                try:
                    updated_date = datetime.strptime(updated.text, DATE_FORMAT)
                except TypeError or ValueError as exception:
                    LOG.error(f"Error parsing updated_time {exception}")
                    updated_date = datetime.min

                if updated_date + OFFLINE_DELAY < datetime.now():
                    LOG.info(f"{entry} switch to offline")
                    summary.text = "offline"
                    updated.text = Main.genTime()
                    Main.findOrCreate(self.feed_tree, "updated").text = Main.genTime()
                    Main.findOrCreate(entry, "id").text = Main.genId()
                    self.tree_updated = True

    def checkLoop(self):
        while True:

            self.cleanNotifs()

            update_list = self.getUpdateList()
            if update_list:
                LOG.info(f"New update detected {update_list}")
                for update in update_list:
                    self.updateStatus(update)

            notification_list = self.getNotificationList()
            if notification_list:
                LOG.info(f"New notification detected {notification_list}")
                for notification in notification_list:
                    self.updateNotifs(notification[0], notification[1])

            self.checkExpiredEntries()

            if self.tree_updated:
                LOG.info(f"Writing new feed to {ATOM_PATH}")
                self.writeFeedTree()
                self.tree_updated = False

            LOG.info(f"Sleeping for {LOOP_INTERVAL} seconds")
            time.sleep(LOOP_INTERVAL)

    def writeFeedTree(self):
        with TemporaryDirectory(dir=TMP_DIR) as tmpdirname:
            LOG.debug(f"Writing {ATOM_PATH}")
            filepath = os.path.join(tmpdirname, "atom.xml")
            self.tree.write(filepath, encoding="utf-8", xml_declaration=True)
            shutil.move(filepath, ATOM_PATH)

    @staticmethod
    def addNotification(title, summary):
        LOG.info(f"Writing notification: {title}")
        file_path = os.path.join(
            NOTIFICATION_UPDATE_LOCATION, str(round(time.time() * 100000))
        )
        try:
            with open(file_path, "w") as file:
                file.write(title + os.linesep + summary)
        except Exception as write_exception:
            LOG.error(f"Error trying to write {file_path}: {write_exception}")

    @staticmethod
    def addUpdate(host):
        LOG.info(f"Writing host update: {host}")
        file_path = os.path.join(FEED_UPDATE_LOCATION, host)
        try:
            open(file_path, "a").close()
        except Exception as write_exception:
            LOG.error(f"Error trying to write {file_path}: {write_exception}")

    def run(self):
        if len(sys.argv) < 2:
            raise Exception(USAGE)
        if sys.argv[1] == "loop":
            self.checkLoop()
        elif sys.argv[1] == "notif":
            if len(sys.argv) != 4:
                raise Exception(USAGE)
            Main.addNotification(sys.argv[2], sys.argv[3])
        elif sys.argv[1] == "update":
            if len(sys.argv) != 3:
                raise Exception(USAGE)
            Main.addUpdate(sys.argv[2])
        else:
            raise Exception(USAGE)


if __name__ == "__main__":
    LOG.info(f"Starting feed-update loop in {START_DELAY} seconds")
    time.sleep(START_DELAY)
    Main().run()
