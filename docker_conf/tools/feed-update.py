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


#TMP_DIR = "/run/"
TMP_DIR = os.path.join("/run/user/", str(os.getuid()))
ATOM_PATH = "/tmp/atom.xml"
# ATOM_PATH = "/docker-data/nginx/status/atom.xml"
PID_LOCATION = "/run/feed-update"

LOOP_INTERVAL = "1200"
OFFLINE_DELAY = timedelta(hours=1)

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

DATE_FORMAT = "%Y-%m-%dT%H:%M:%SZ"
NS = {"": "http://www.w3.org/2005/Atom"}
PRE_ID = "urn:uuid:"
logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
LOG = logging.getLogger("YDL")


class Main:
    @staticmethod
    def genId():
        return PRE_ID + str(uuid.uuid1())

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

    def importTree(self):
        try:
            ET.register_namespace("", "http://www.w3.org/2005/Atom")
            LOG.debug(f"Retrieving {ATOM_PATH}")
            self.tree = ET.parse(ATOM_PATH)
            if self.tree is None:
                raise Exception("Feed empty")
            self.feed_tree = self.tree.getroot()
            # TODO custom exception
        except Exception as exception:
            LOG.debug(f"{exception}")
            LOG.error(f"{ATOM_PATH} retrieving failed, creating new feed")
            self.tree = ET.ElementTree(ET.fromstring(
                SAMPLE_ATOM.replace("[HOST]", self.host)
                .replace("[ID]", Main.genId())
                .replace("[TIME]", Main.genTime()))
            )
            self.feed_tree = self.tree.getroot()

    def updateStatus(self, host):
        titles = self.feed_tree.findall('./entry/title[.="' + host + '"]', NS)
        if not titles:
            ET.register_namespace("", "http://www.w3.org/2005/Atom")
            entry = ET.fromstring(
                SAMPLE_ENTRY.replace("[HOST]", self.host).replace("[HOST2]", host).replace("[ID]", Main.genId())
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
        self.writeFeedTree()

    def checkLoop(self):
        while True:
            LOG.info(f"Sleeping for {LOOP_INTERVAL} seconds")
            time.sleep(LOOP_INTERVAL)
            last_modification_time = time.ctime(os.path.getmtime(ATOM_PATH))
            LOG.debug(f"Last modification time {ATOM_PATH} : {last_modification_time}")
            if self.last_feed_update != last_modification_time:
                LOG.info(
                    f"{ATOM_PATH} modified at {last_modification_time}, checking entries"
                )
                entries = self.feed_tree.findall("./entry", NS)
                for entry in entries:
                    summary = Main.findOrCreate(entry, "summary")
                    updated = Main.findOrCreate(entry, "updated")
                    try:
                        updated_date = (
                            datetime.strptime(updated.text, DATE_FORMAT) - OFFLINE_DELAY
                        )
                    except TypeError or ValueError:
                        updated_date = datetime.now() - OFFLINE_DELAY
                    if (
                        summary.text == "online"
                        and updated_date + OFFLINE_DELAY < datetime.now()
                    ):
                        LOG.info(f"{entry} switch to offline")
                        summary.text = "offline"
                        updated.text = Main.genTime()
                        Main.findOrCreate(self.feed_tree, "updated").text = Main.genTime()
                        Main.findOrCreate(entry, "id").text = Main.genId()
                self.writeFeedTree()
                self.last_feed_update = time.ctime(os.path.getmtime(ATOM_PATH))

    def writeFeedTree(self):
        with TemporaryDirectory(dir=TMP_DIR) as tmpdirname:
            LOG.debug(f"Writing {ATOM_PATH}")
            filepath = os.path.join(tmpdirname, "atom.xml")
            self.tree.write(filepath, encoding='utf-8', xml_declaration=True)
            shutil.move(filepath, ATOM_PATH)

    def run(self):
        # args : updateStatus | check loop | notif
        # add PID lock :
        # PID_LOCATION="/var/run/feed-update-$arg"
        # updateStatus | notif = wait until -> recheck loop, sleep 5s, max 3 loops
        # TODO pid queue, worth ?
        # check loop = first one only -> next ones raise Exception
        if len(sys.argv) != 2:
            LOG.error("Must have 1 arg")
            sys.exit(1)
        self.updateStatus(sys.argv[1])

    # notif fct

    #TODO comments + moar logs


if __name__ == "__main__":
    Main().run()
