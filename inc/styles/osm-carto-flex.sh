#----------------------------------------------------
#
# CartoOsm style sheet - the current OSM default style
#
#----------------------------------------------------

cd $STYLEDIR

git clone --quiet https://github.com/gravitystorm/openstreetmap-carto.git openstreetmap-carto-flex
cd openstreetmap-carto-flex
git checkout --quiet master

patch -p1 < $INCDIR/styles/osm-carto-flex.patch
carto --quiet --api $MAPNIK_VERSION_FOR_CARTO project.mml > osm.xml

php $FILEDIR/tools/postprocess-style.php osm.xml

# create color-reduced variant of generated style

php $FILEDIR/tools/make-style-monochrome.php

chown -R maposmatic .
