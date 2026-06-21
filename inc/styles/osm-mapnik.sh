#! /bin/bash -e
#----------------------------------------------------
#
# Fetch old pre-Carto OSM Mapnik stylesheed
#
# we won't really use it as it is outdated, but we need its symbol dir
# for the maposmatic printable stylesheet later
#
#----------------------------------------------------


pushd . > /dev/null

cd "$STYLEDIR"

git clone https://github.com/openstreetmap/mapnik-stylesheets mapnik2-osm
cd mapnik2-osm
ln -s "$SHAPEFILE_DIR"/world_boundaries .

cp "$FILEDIR"/styles/mapnik2-osm/* inc

cd ..

popd > /dev/null
