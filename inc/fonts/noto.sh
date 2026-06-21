#! /bin/bash -e

DOWNLOAD_DIR=${CACHEDIR:-/vagrant/cache}/fonts
mkdir -p $DOWNLOAD_DIR

FONTDIR=/usr/local/share/fonts/truetype/noto
mkdir -p $FONTDIR

cd $DOWNLOAD_DIR
wget --timestamping https://noto-website-2.storage.googleapis.com/pkgs/Noto-unhinted.zip

cd $FONTDIR
unzip -qf $DOWNLOAD_DIR/Noto-unhinted.zip
