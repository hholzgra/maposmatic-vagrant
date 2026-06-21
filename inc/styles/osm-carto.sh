#! /bin/bash -e
#----------------------------------------------------
#
# CartoOsm style sheet - the current OSM default style
#
#----------------------------------------------------

pushd . > /dev/null

cd "$STYLEDIR"

git clone --quiet https://github.com/gravitystorm/openstreetmap-carto.git
cd openstreetmap-carto
git checkout --quiet v5.2.0

ln -s "$SHAPEFILE_DIR" data

sed '/\sname:/d' < project.mml > osm.mml
patch -p1 < "$INCDIR"/styles/osm-carto.patch
carto --quiet --api "$MAPNIK_VERSION_FOR_CARTO" osm.mml > osm.xml
php "$FILEDIR"/tools/postprocess-style.php osm.xml

# create color-reduced variant of generated style

php "$FILEDIR"/tools/make-style-monochrome.php

popd > /dev/null 
