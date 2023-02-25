#! /bin/bash

cd $STYLEDIR

git clone --quiet https://github.com/hholzgra/veloroad.git
cd veloroad

mkdir -p data
ln -s $SHAPEFILE_DIR/water-polygons-split-3857 data
ln -s $SHAPEFILE_DIR/gmted25 data/gmted

curl -z data/ptsans.zip -L -o data/ptsans.zip https://www.fontsquirrel.com/fonts/download/pt-sans
unzip -o data/ptsans.zip -d data/ptsans

curl -z data/ptsans/DroidSansFallback.ttf -L -o data/ptsans/DroidSansFallback.ttf https://github.com/android/platform_frameworks_base/raw/master/data/fonts/DroidSansFallback.ttf

sed '/"name":/d' < project.mml > osm.mml
carto -q -a $(MAPNIK_VERSION_FOR_CARTO) osm.mml > veloroad.xml

