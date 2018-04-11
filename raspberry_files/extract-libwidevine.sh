#!/bin/bash
wget http://odroidxu.leeharris.me.uk/xu3/chromium-widevine-1.4.8.823-2-armv7h.pkg.tar.xz -O /tmp/chromium-widevine-1.4.8.823-2-armv7h.pkg.tar.xz 
tar xJf /tmp/chromium-widevine-1.4.8.823-2-armv7h.pkg.tar.xz usr/lib/chromium/libwidevinecdm.so --strip-components=3 
chmod 755 libwidevinecdm.so 
if [ ! -d "/home/osmc/.kodi/cdm/" ]; then
 mkdir /home/osmc/.kodi/cdm/ 
fi 
cp -ar libwidevinecdm.so /home/osmc/.kodi/cdm/
ln -fs /usr/lib/kodi/addons/inputstream.adaptive/libssd_wv.so /home/osmc/.kodi/cdm/libssd_wv.so

# sudo nano /etc/apt/sources.list
# add 
# deb http://download.osmc.tv/dev/gmc-18 gmc-18 main
# wget -qO - http://download.osmc.tv/dev/gmc-18/gpg.key | sudo apt-key add
# sudo apt-get update
# sudo apt-get dist-upgrade
# sudo systemctl start mediacenter
# sudo apt-get install xz-utils

# chmod +x extract-libwidevine.sh
# ./extract-libwidevine.sh

# sudo apt-get install python-crypto
# sudo apt-get install build-essential python-pip
# sudo pip install -U setuptools
# sudo pip install wheel
# sudo pip install pycryptodomex

# wget https://github.com/gismo112/plugin.video.netflix/archive/master.zip 
# mv master.zip  plugin.video.netflix.zip

# install repo then netflix
