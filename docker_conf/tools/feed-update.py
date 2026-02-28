#!/usr/bin/python3
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

LOG = logging.getLogger("Feed-Update")
logging.basicConfig(level=logging.INFO)

TMP_DIR = "/run/feed/"
ATOM_PATH = "/docker-data/nginx/static/status/atom.xml"
FEED_UPDATE_LOCATION = "/var/tmp/feed/updates/"
NOTIFICATION_UPDATE_LOCATION = "/var/tmp/feed/notifications/"

LOOP_INTERVAL = 900
OFFLINE_DELAY = timedelta(hours=1)
MAX_NOTIFICATIONS = 50
MAX_NOTIFICATION_AGE = timedelta(days=30)

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
UPDATE_ENTRY = """<entry>
    <title>[HOST2]</title>
    <category term="update"/>
    <link href="https://status.[HOST]/#[HOST2_LINK]"/>
    <id>[ID]</id>
    <updated>""</updated>
    <summary>online</summary>
  </entry>"""
NOTIFICATION_ENTRY = """<entry >
    <title>[TITLE]</title>
    <category term="notif"/>
    <link href="https://status.[HOST]/#[TITLE_LINK]"/>
    <id>[ID]</id>
    <updated>[UPDATED]</updated>
    <summary>[MESSAGE]</summary>
  </entry>"""

XMLD = "http://www.w3.org/2005/Atom"
NS = {"": XMLD}


class Main:
    @staticmethod
    def genId():
        return "urn:uuid:" + str(uuid.uuid1())

    @staticmethod
    def genTime():
        return datetime.now().astimezone().replace(microsecond=0).isoformat()

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
        os.makedirs(TMP_DIR, exist_ok=True)

    @staticmethod
    def checkPath():
        if not os.path.isfile(ATOM_PATH):
            i = 1
            while not os.path.isfile(ATOM_PATH):
                if i > 5:
                    raise Exception(f"{ATOM_PATH} not detected, exiting")
                LOG.info(f"{ATOM_PATH} not detected, waiting ({i})")
                time.sleep(300)
                i = i + 1
            LOG.info(f"{ATOM_PATH} detected, starting")

    def __init__(self):
        Main.init_dirs()
        self.feed_tree = None
        self.tree = None
        self.tree_updated = False
        self.host = socket.gethostname()

    def importTree(self):
        # Import existing ATOM_PATH, or create a new one
        try:
            ET.register_namespace("", XMLD)
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
                file_path = os.path.join(FEED_UPDATE_LOCATION, file)
                update_list.append((file, os.path.getmtime(file_path)))
                os.remove(file_path)
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
                        datetime.fromtimestamp(os.path.getmtime(file_path))
                        .astimezone()
                        .replace(microsecond=0)
                        .isoformat(),
                    )
                    update_list.append(tup)
                os.remove(file_path)
        except Exception as read_exception:
            LOG.error(
                f"Error trying to read {NOTIFICATION_UPDATE_LOCATION}: {read_exception}"
            )
        return update_list

    def updateStatus(self, status):
        # Update a status entry
        host = str(status[0])
        updated = (
            datetime.fromtimestamp(status[1])
            .astimezone()
            .replace(microsecond=0)
            .isoformat()
        )
        titles = self.feed_tree.findall('./{*}entry/{*}title[.="' + host + '"]', NS)
        if not titles:
            ET.register_namespace("", XMLD)
            entry = ET.fromstring(
                UPDATE_ENTRY.replace("[HOST]", self.host.strip())
                .replace("[HOST2]", host)
                .replace("[HOST2_LINK]", host.strip().replace(" ", "_"))
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
                    Main.findOrCreate(entry, "updated").text = updated
                    Main.findOrCreate(self.feed_tree, "updated").text = Main.genTime()
                else:
                    summary.text = "online"
                    Main.findOrCreate(entry, "updated").text = updated
                    Main.findOrCreate(self.feed_tree, "updated").text = Main.genTime()
                    Main.findOrCreate(entry, "id").text = Main.genId()
            else:
                try:
                    parent_map[title].remove(title)
                except ValueError:
                    pass
        self.tree_updated = True

    def cleanNotifsByLen(self):
        # Remove oldest notifs if too many (MAX_NOTIFICATIONS)
        parent_map = {c: p for p in self.feed_tree.iter() for c in p}
        categories_notif = self.feed_tree.findall(
            './{*}entry/{*}category[@term="notif"]', NS
        )
        entries = [parent_map[cat] for cat in categories_notif]
        if len(entries) > MAX_NOTIFICATIONS:
            LOG.info("Too many notifications detected, removing oldest ones")
            entries_to_remove = entries[:MAX_NOTIFICATIONS]
            for entry_to_remove in entries_to_remove:
                parent_map[entry_to_remove].remove(entry_to_remove)
            self.tree_updated = True

    def cleanNotifsByAge(self):
        # Remove oldest notifs (MAX_NOTIFICATION_AGE)
        parent_map = {c: p for p in self.feed_tree.iter() for c in p}
        categories_notif = self.feed_tree.findall(
            './{*}entry/{*}category', NS
        )
        entries = [parent_map[cat] for cat in categories_notif]
        entry_to_remove = []
        for entry in entries:
            updated_text = Main.findOrCreate(entry, "updated").text
            try:
                updated_date = datetime.fromisoformat(updated_text)
            except TypeError or ValueError as exception:
                LOG.error(f"Error parsing updated_time {exception}")
                updated_date = datetime.min
            if updated_date + MAX_NOTIFICATION_AGE < datetime.now().astimezone():
                entry_to_remove.append(entry)
        for entry in entry_to_remove:
            LOG.info(
                f"Notification expired (max age {MAX_NOTIFICATION_AGE}), removing\n{ET.tostring(entry)}"
            )
            parent_map[entry].remove(entry)
            self.tree_updated = True

    def createNotification(self, notification):
        # Create a new notification
        title, message, updated = notification
        ET.register_namespace("", XMLD)
        entry = ET.fromstring(
            NOTIFICATION_ENTRY.replace("[HOST]", self.host)
            .replace("[HOST]", self.host)
            .replace("[TITLE]", str(title))
            .replace("[TITLE_LINK]", str(title).strip().replace(" ", "_"))
            .replace("[ID]", Main.genId())
            .replace("[MESSAGE]", str(message))
            .replace("[UPDATED]", str(updated))
        )
        self.feed_tree.append(entry)
        Main.findOrCreate(self.feed_tree, "updated").text = Main.genTime()
        self.tree_updated = True

    def checkExpiredEntries(self):
        # Check online entries if no new update for too long -> offline
        parent_map = {c: p for p in self.feed_tree.iter() for c in p}
        categories_update = self.feed_tree.findall(
            './{*}entry/{*}category[@term="update"]', NS
        )
        entries = [parent_map[cat] for cat in categories_update]
        for entry in entries:
            summary = Main.findOrCreate(entry, "summary")
            if summary.text == "online":
                updated = Main.findOrCreate(entry, "updated")
                try:
                    updated_date = datetime.fromisoformat(updated.text)
                except TypeError or ValueError as exception:
                    LOG.error(f"Error parsing updated_time {exception}")
                    updated_date = datetime.min

                if updated_date + OFFLINE_DELAY < datetime.now().astimezone():
                    LOG.info(f"{entry} switch to offline")
                    summary.text = "offline"
                    updated.text = Main.genTime()
                    Main.findOrCreate(self.feed_tree, "updated").text = Main.genTime()
                    Main.findOrCreate(entry, "id").text = Main.genId()
                    self.tree_updated = True

    def checkLoop(self):
        LOG.info("Starting feed_update check loop")
        Main.checkPath()
        self.importTree()
        # Infinite check loop
        while True:
            # Clean overflowing notifications
            self.cleanNotifsByLen()

            # Clean oldest notifications
            self.cleanNotifsByAge()

            # Retrieve and append new status update
            update_list = self.getUpdateList()
            if update_list:
                LOG.info(f"New update detected {update_list}")
                for update in update_list:
                    self.updateStatus(update)

            # Retrieve and append new notifications
            notification_list = self.getNotificationList()
            if notification_list:
                LOG.info(f"New notification detected {notification_list}")
                for notification in notification_list:
                    self.createNotification(notification)

            # Check and switch expired update entries
            self.checkExpiredEntries()

            # If changes write new atom.xml
            if self.tree_updated:
                self.writeFeedTree()
                self.tree_updated = False

            LOG.debug(f"Sleeping for {LOOP_INTERVAL} seconds")
            time.sleep(LOOP_INTERVAL)

    def writeFeedTree(self):
        # Write file in temp dir, then overwrite/move to ATOM_PATH
        with TemporaryDirectory(dir=TMP_DIR) as tmpdirname:
            LOG.info(f"Writing new feed to {ATOM_PATH}")
            filepath = os.path.join(tmpdirname, "atom.xml")
            self.tree.write(filepath, encoding="utf-8", xml_declaration=True)
            shutil.move(filepath, ATOM_PATH)

    @staticmethod
    def addNotification(title, summary):
        # Create a new notification for the check loop
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
        # Create a new status update for the check loop
        LOG.info(f"Writing host update: {host}")
        file_path = os.path.join(FEED_UPDATE_LOCATION, host)
        try:
            with open(file_path, "a"):
                os.utime(file_path)
        except Exception as write_exception:
            LOG.error(f"Error trying to write {file_path}: {write_exception}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise Exception(USAGE)
    if sys.argv[1] == "loop":
        if len(sys.argv) != 2:
            raise Exception(USAGE)
        Main().checkLoop()
    elif sys.argv[1] == "notif":
        if len(sys.argv) != 4:
            raise Exception(USAGE)
        Main().addNotification(sys.argv[2], sys.argv[3])
    elif sys.argv[1] == "update":
        if len(sys.argv) != 3:
            raise Exception(USAGE)
        Main().addUpdate(sys.argv[2])
    else:
        raise Exception(USAGE)
