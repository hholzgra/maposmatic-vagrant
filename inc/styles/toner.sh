#! /bin/bash

cd /home/maposmatic/styles

git clone --quiet https://github.com/geofabrik/toner.git

cd toner

ln -s toner.mml project.mml

rm -rf data
ln -s /home/maposmatic/shapefiles data

sed '/"name":/d' < toner.mml > osm.mml
carto -a $(mapnik-config -v) --quiet osm.mml > toner.xml
php /vagrant/files/tools/postprocess-style.php toner.xml

sudo -u maposmatic psql gis < sql/functions/highroad.sql 

