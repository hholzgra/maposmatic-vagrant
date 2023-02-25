#! /bin/bash

cd $STYLEDIR

git clone --quiet https://github.com/geofabrik/toner.git

cd toner

ln -s toner.mml project.mml

rm -rf data
ln -s $SHAPEFILE_DIR data

sed '/"name":/d' < toner.mml > osm.mml
carto -a $MAPNIK_VERSION_FOR_CARTO --quiet osm.mml > toner.xml
php $FILEDIR/tools/postprocess-style.php toner.xml

sudo -u maposmatic psql gis < sql/functions/highroad.sql 

