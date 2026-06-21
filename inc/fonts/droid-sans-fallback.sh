#! /bin/bash -e

pushd .

DOWNLOAD_DIR=${CACHEDIR:-/vagrant/cache}/fonts
mkdir -p "$DOWNLOAD_DIR"

FONTDIR=/usr/local/share/fonts/truetype/droid-sans-fallback
mkdir -p "$FONTDIR"

cd $DOWNLOAD_DIR
wget --timestamping https://github.com/android/platform_frameworks_base/raw/master/data/fonts/DroidSansFallback.ttf -O DroidSansFallback.ttf

cp DroidSansFallback.ttf $FONTDIR

# FIXME -> run this at end of font provisioning once only?
fc-cache -f # not needed for Mapnik, but good practice nonetheless

popd
