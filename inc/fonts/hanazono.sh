DOWNLOAD_DIR=${CACHEDIR:-/vagrant/cache}/fonts
mkdir -p $DOWNLOAD_DIR

FONTDIR=/usr/local/share/fonts/truetype/hanazono
mkdir -p $FONTDIR

wget --timestamping 'https://mirrors.dotsrc.org/osdn/hanazono-font/68253/hanazono-20170904.zip' -O $DOWNLOAD_DIR/hanazono.zip

cd $FONTDIR
unzip -oqq "$DOWNLOAD_DIR/hanazono.zip" HanaMinA.ttf HanaMinB.ttf

fc-cache -f
