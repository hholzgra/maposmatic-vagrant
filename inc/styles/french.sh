#! /bin/bash

cd $STYLEDIR

git clone --quiet https://github.com/cquest/osmfr-cartocss.git
cd osmfr-cartocss
git checkout --quiet v2.8.0

ln -s $SHAPEFILE_DIR data

sed '/"name":/d' < project.mml > osm.mml
carto -q -a $(MAPNIK_VERSION_FOR_CARTO) osm.mml > osm.xml

