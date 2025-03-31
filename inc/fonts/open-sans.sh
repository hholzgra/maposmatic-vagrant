DOWNLOAD_DIR=${CACHEDIR:-/vagrant/cache}/fonts
mkdir -p $DOWNLOAD_DIR

FONTDIR=/usr/local/share/fonts/truetype/open-sans
mkdir -p $FONTDIR

cd $DOWNLOAD_DIR

## opensans website currently out of order
# wget --timestamping https://www.opensans.com/download/open-sans.zip -O open-sans.zip
# wget --timestamping https://www.opensans.com/download/open-sans-condensed.zip -O open-sans-condensed.zip
## install from local backup copies
wget --timestamping https://get-map.org/downloads/open-sans.zip -O open-sans.zip
wget --timestamping https://get-map.org/downloads/open-sans-condensed.zip -O open-sans-condensed.zip

cd $FONTDIR
unzip -qf $DOWNLOAD_DIR/open-sans.zip 
unzip -qf $DOWNLOAD_DIR/open-sans-condensed.zip

# FIXME -> run this at end of font provisioning once only?
fc-cache -f # not needed for Mapnik, but good practice nonetheless


