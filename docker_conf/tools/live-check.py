import xml.etree.ElementTree as ET
import time
from datetime import datetime
import os
import socket
import uuid

LOOP_INTERVAL = "30min"
OFFLINE_DELAY = "2h"
SAMPLE_ATOM = """<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>[HOST] feed</title>
  <link href="https://[DOMAIN]/status/"/>
  <updated>[TIME]</updated>
  <author>
    <name>[DOMAIN]</name>
  </author>
  <id>[ID]</id>
</feed>"""
SAMPLE_ENTRY = """<entry>
    <title>[HOST]</title>
    <link href="https://[HOST]/status#[HOST2]"/>
    <id></id>
    <updated></updated>
    <summary></summary>
  </entry>"""

ATOM_PATH = "/docker-data/nginx/status/atom.xml"
NS = {"": "http://www.w3.org/2005/Atom"}
PRE_ID = "urn:uuid:"


class Main:
    def __init__(self):
        self.host = socket.gethostname()
        self.last_rss_update = None
        self.feed_tree = None
        self.tree = None

    @staticmethod
    def genId():
        return PRE_ID + str(uuid.uuid1())

    @staticmethod
    def genTime():
        return datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")

    def importTree(self):
        try:
            self.last_rss_update = time.ctime(os.path.getmtime(ATOM_PATH))
            ET.register_namespace("", "http://www.w3.org/2005/Atom")
            self.tree = ET.parse("filepath")
            if self.feed_tree is None:
                raise
            self.feed_tree = self.tree.getroot()
            # TODO custom exception
        except Exception:
            self.tree = ET.fromstring(
                SAMPLE_ATOM.replace("[HOST]", self.host)
                .replace("[ID]", Main.genId())
                .replace("[TIME]", Main.genTime())
            )
            self.feed_tree.getroot()

    @staticmethod
    def findOrCreate(element, subelement_str):
        subelement = element.find(subelement_str, NS)
        if subelement is None:
            subelement = ET.Element(subelement_str)
            element.append(subelement)
        return subelement

    def updateStatus(self, host, status):
        titles = self.feed_tree.findall('./entry/title[.="' + self.host + '"]', NS)
        if not titles:
            ET.register_namespace("", "http://www.w3.org/2005/Atom")
            entry = ET.fromstring(
                SAMPLE_ENTRY.replace("[HOST]", self.host).replace("[HOST2]", host)
            )
            self.feed_tree.append(entry)
            titles = [entry]

        for title in titles:
            parent_map = {c: p for p in self.feed_tree.iter() for c in p}
            if titles[0] == title:
                entry = parent_map[title]
                summary = entry.findOrCreate("summary")
                if summary.text == status:
                    entry.findOrCreate("updated").text = Main.genTime()
                    self.feed_tree.findOrCreate("updated").text = Main.genTime()
                else:
                    summary.text = status
                    entry.findOrCreate("updated").text = Main.genTime()
                    self.feed_tree.findOrCreate("updated").text = Main.genTime()
                    entry.findOrCreate("id").text = Main.genId()

            parent_map[title].remove(title)
        self.tree.write(ATOM_PATH)
     

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
