#! /bin/bash

cd $STYLEDIR

git clone --quiet https://github.com/OpenRailwayMap/OpenRailwayMap-CartoCSS

cd OpenRailwayMap-CartoCSS

sudo -u maposmatic psql gis < sql/osm_carto_views.sql
sudo -u maposmatic psql gis < sql/functions.sql
sudo -u maposmatic psql gis < sql/get_station_importance.sql

for carto_style in *.mml
do
	mapnik_style=$(basename $carto_style .mml).xml
	carto -a $(MAPNIK_VERSION_FOR_CARTO) --quiet $carto_style  > $mapnik_style
        php $FILEDIR/tools/postprocess-style.php $mapnik_style
done


