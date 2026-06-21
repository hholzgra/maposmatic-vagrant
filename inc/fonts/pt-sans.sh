#! /bin/bash -e

pushd .

DOWNLOAD_DIR=${CACHEDIR:-/vagrant/cache}/fonts
mkdir -p "$DOWNLOAD_DIR"

FONTDIR=/usr/local/share/fonts/truetype/pt-sans
mkdir -p "$FONTDIR"

cd $DOWNLOAD_DIR
wget --timestamping https://www.fontsquirrel.com/fonts/download/pt-sans/pt-sans.zip

cd $FONTDIR
unzip -qf $DOWNLOAD_DIR/pt-sans.zip

# FIXME -> run this at end of font provisioning once only?
fc-cache -f # not needed for Mapnik, but good practice nonetheless

popd
