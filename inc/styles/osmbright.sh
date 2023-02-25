#! /bin/bash

cd $STYLEDIR

git clone --quiet https://github.com/hholzgra/osm-bright.git

cd osm-bright

ln -s $SHAPEFILE_DIR shp

cp $FILEDIR/config-files/osmbright-configure.py configure.py

./make.py

cd OSMBright
sed '/"name":/d' < project.mml > osm.mml
carto -q -a $(MAPNIK_VERSION_FOR_CARTO) osm.mml  > osm.xml

