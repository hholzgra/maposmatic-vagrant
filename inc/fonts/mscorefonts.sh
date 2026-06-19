#! /bin/bash -e

echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
apt-get install -y -f ttf-mscorefonts-installer > /dev/null
