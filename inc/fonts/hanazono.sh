#! /bin/bash -e

pushd . > /dev/null

DOWNLOAD_DIR=${CACHEDIR:-/vagrant/cache}/fonts
mkdir -p "$DOWNLOAD_DIR"

FONTDIR=/usr/local/share/fonts/truetype/hanazono
mkdir -p "$FONTDIR"

for url in 'https://mirrors.dotsrc.org/osdn/hanazono-font/68253/hanazono-20170904.zip' 'http://get-map.org/downloads/hanazono.zip'
do
  if wget --timestamping $url -O "$DOWNLOAD_DIR/hanazono.zip"
  then
    break
  fi
done

test -s "$DOWNLOAD_DIR/hanazono.zip"

cd $FONTDIR
unzip -oqq "$DOWNLOAD_DIR/hanazono.zip" HanaMinA.ttf HanaMinB.ttf

popd > /dev/null
