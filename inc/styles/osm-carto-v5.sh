#----------------------------------------------------
#
# CartoOsm style sheet - the current OSM default style
#
#----------------------------------------------------

cd $STYLEDIR

git clone --quiet https://github.com/gravitystorm/openstreetmap-carto.git openstreetmap-carto-v5
cd openstreetmap-carto-v5
git checkout --quiet v5.8.0

sed '/\sname:/d' < project.mml > osm.mml
patch -p1 < $INCDIR/styles/osm-carto.patch
carto --quiet --api $MAPNIK_VERSION_FOR_CARTO osm.mml > osm.xml
php $FILEDIR/tools/postprocess-style.php osm.xml

# create color-reduced variant of generated style

php $FILEDIR/tools/make-style-monochrome.php

chown -R maposmatic .
