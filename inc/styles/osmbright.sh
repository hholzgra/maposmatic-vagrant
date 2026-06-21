#! /bin/bash -e

pushd . > /dev/null

cd "$STYLEDIR"

git clone --quiet https://github.com/hholzgra/osm-bright.git

cd osm-bright

ln -s "$SHAPEFILE_DIR" shp

sed -e "s|@SHAPEFILE_DIR@|$SHAPEFILE_DIR|g" < "$FILEDIR"/config-files/osmbright-configure.py > configure.py

./make.py

cd OSMBright
sed '/"name":/d' < project.mml > osm.mml
carto --quiet --api "$MAPNIK_VERSION_FOR_CARTO" osm.mml  > osm.xml

popd > /dev/null
