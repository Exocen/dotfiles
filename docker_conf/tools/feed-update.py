import xml.etree.ElementTree as ET
import time
from datetime import datetime, timedelta
import os
import sys
import logging
import socket
import shutil
import uuid
from tempfile import TemporaryDirectory


# TMP_DIR = "/run/"
TMP_DIR = os.path.join("/run/user/", str(os.getuid()))
ATOM_PATH = "/tmp/atom.xml"
# ATOM_PATH = "/docker-data/nginx/status/atom.xml"

# TODO create those at start or check presence
# can be volatil
FEED_UPDATE_LOCATION = "/run/feed/update/"
# must be persistent
NOTIFICATION_UPDATE_LOCATION = "/run/feed/notifications/"

LOOP_INTERVAL = "1200"
OFFLINE_DELAY = timedelta(hours=1)
MAX_NOTIFICATIONS = 10

USAGE = "Usage: feed-update.py [ loop | notif | update ] \n loop -> run check loop \n notif -> add a notification (title+text) \n update -> update/add given host"
SAMPLE_ATOM = """<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>[HOST] feed</title>
  <link href="https://[HOST]/status/atom.xml" rel="self" />
  <updated>[TIME]</updated>
  <author>
    <name>[HOST]</name>
  </author>
  <id>[ID]</id>
</feed>"""
SAMPLE_ENTRY = """<entry>
    <title>[HOST2]</title>
    <link href="https://[HOST]/status#[HOST2]"/>
    <id>[ID]</id>
    <updated>""</updated>
    <summary>online</summary>
  </entry>"""
NOTIFICATION_ENTRY = """<entry type='notif'>
    <title>[TITLE]</title>
    <link href="https://[HOST]/status#[TITLE]"/>
    <id>[ID]</id>
    <updated>[UPDATED]</updated>
    <summary>[MESSAGE]</summary>
  </entry>"""

DATE_FORMAT = "%Y-%m-%dT%H:%M:%SZ"
NS = {"": "http://www.w3.org/2005/Atom"}
logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
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

    def __init__(self):
        self.host = socket.gethostname()
        self.last_feed_update = 0
        self.feed_tree = None
        self.tree = None
        self.importTree()
        self.tree_updated = False

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
            LOG.error(f"{ATOM_PATH} retrieving failed, creating new feed")
            self.tree = ET.ElementTree(
                ET.fromstring(
                    SAMPLE_ATOM.replace("[HOST]", self.host)
                    .replace("[ID]", Main.genId())
                    .replace("[TIME]", Main.genTime())
                )
            )
            self.feed_tree = self.tree.getroot()

    def getUpdateList(self):
        # Return list of host to update
        LOG.debug(f"Getting files from {self.FEED_UPDATE_LOCATION}")
        update_list = []
        try:
            file_list = os.listdir(os.listdir(self.FEED_UPDATE_LOCATION))
            for file in file_list:
                update_list.append(os.path.basename(file))
                os.remove(file)
        except Exception as read_exception:
            LOG.error(
                f"Error trying to read {self.FEED_UPDATE_LOCATION}: {read_exception}"
            )
        return update_list

    def getNotificationSet(self):
        # Return set of notification to add to the feed key=>title and value=>summary
        LOG.debug(f"Getting files from {self.NOTIFICATION_UPDATE_LOCATION}")
        update_set = set()
        try:
            file_list = os.listdir(os.listdir(self.NOTIFICATION_UPDATE_LOCATION))
            for file in file_list:
                with open(file, "r") as file_buf:
                    update_set[os.path.basename(file)] = file_buf.read().rstrip()
                os.remove(file)
        except Exception as read_exception:
            LOG.error(
                f"Error trying to read {self.NOTIFICATION_UPDATE_LOCATION}: {read_exception}"
            )
        return update_set

    def updateStatus(self, host):
        titles = self.feed_tree.findall('./entry/title[.="' + host + '"]', NS)
        if not titles:
            ET.register_namespace("", "http://www.w3.org/2005/Atom")
            entry = ET.fromstring(
                SAMPLE_ENTRY.replace("[HOST]", self.host)
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
                    summary.text = "offline"
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
        # TODO remove oldest notifs if too many
        # parent_map = {c: p for p in self.feed_tree.iter() for c in p}
        # entries = self.feed_tree.findall('./entry[@type="notif"]', NS)
        # MAX_NOTIFICATIONS
        pass

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
        # check online entries if no new update for too long -> offline
        entries = self.feed_tree.findall("./entry", NS)
        for entry in entries:
            summary = Main.findOrCreate(entry, "summary")
            if summary.text == "online":
                updated = Main.findOrCreate(entry, "updated")
                try:
                    updated_date = (
                        datetime.strptime(updated.text, DATE_FORMAT) - OFFLINE_DELAY
                    )
                except TypeError or ValueError:
                    updated_date = datetime.now() - OFFLINE_DELAY

                if updated_date + OFFLINE_DELAY < datetime.now():
                    LOG.info(f"{entry} switch to offline")
                    summary.text = "offline"
                    updated.text = Main.genTime()
                    Main.findOrCreate(self.feed_tree, "updated").text = Main.genTime()
                    Main.findOrCreate(entry, "id").text = Main.genId()
                    self.tree_updated = True

    def checkLoop(self):
        while True:
            LOG.info(f"Sleeping for {LOOP_INTERVAL} seconds")
            time.sleep(LOOP_INTERVAL)

            self.cleanNotifs()

            update_list = self.getUpdateList
            if update_list:
                LOG.info(f"New update detected {update_list}")
                for update in update_list:
                    self.updateStatus(update)

            notification_set = self.getNotificationSet()
            if notification_set:
                LOG.info(f"New notification detected {notification_set}")
                for notification in notification_set:
                    self.updateNotifs(notification[0], notification[1])

            self.checkExpiredEntries()

            if self.tree_updated:
                LOG.info(f"Writing new feed to {ATOM_PATH}")
                self.writeFeedTree()
                self.tree_updated = False

    def writeFeedTree(self):
        with TemporaryDirectory(dir=TMP_DIR) as tmpdirname:
            LOG.debug(f"Writing {ATOM_PATH}")
            filepath = os.path.join(tmpdirname, "atom.xml")
            self.tree.write(filepath, encoding="utf-8", xml_declaration=True)
            shutil.move(filepath, ATOM_PATH)

    def addNotification(self, title, summary):
        #TODO redo
         with TemporaryDirectory(dir=TMP_DIR) as tmpdirname:
            LOG.debug(f"Writing notification: {}")
            # name + timestamp
            filepath = os.path.join(tmpdirname, "atom.xml")
            self.tree.write(filepath, encoding="utf-8", xml_declaration=True)
            shutil.move(filepath, ATOM_PATH)

    # add_notif fct
    # filename->title content->summary

    # add_update fct
    # filename->host
    # only one of each host(overwrite)

    def addUpdate(self, host):
        pass

    def run(self):
        #  loop | notif | update
        if len(sys.argv) < 2:
            raise Exception(USAGE)
        if sys.argv[1] == "loop":
            self.checkLoop()
        elif sys.argv[1] == "notif":
            if len(sys.argv) != 3:
                raise Exception(USAGE)
        elif sys.argv[1] == "update":
            if len(sys.argv) != 4:
                raise Exception(USAGE)
        else:
            raise Exception(USAGE)

    

    # TODO comments + moar logs

    # TODO tree xml validate


if __name__ == "__main__":
    Main().run()
