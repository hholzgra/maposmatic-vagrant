DOWNLOAD_DIR=${CACHEDIR:-/vagrant/cache}/fonts
mkdir -p $DOWNLOAD_DIR

FONTDIR=/usr/local/share/fonts/truetype/open-sans
mkdir -p $FONTDIR

cd $DOWNLOAD_DIR
# upstream is https://www.opensans.com/download/
# but is currently broken (2025-03-31)
# so we use cached copies for now
wget --timestamping https://www.get-map.org/downloads/open-sans.zip
wget --timestamping https://www.get-map.org/downloads/open-sans-condensed.zip

cd $FONTDIR
unzip -qf $DOWNLOAD_DIR/open-sans.zip 
unzip -qf $DOWNLOAD_DIR/open-sans-condensed.zip

# FIXME -> run this at end of font provisioning once only?
fc-cache -f # not needed for Mapnik, but good practice nonetheless


