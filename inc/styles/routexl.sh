#! /bin/bash -e

cd $STYLEDIR

git clone --quiet https://github.com/routexl/osm-routexl
cd osm-routexl

ln -s $(realpath ../osm-bright/OSMBright/img) .


carto --quiet --api $MAPNIK_VERSION_FOR_CARTO ../osm-bright/OSMBright/osm.mml  > osm.xml
php $FILEDIR/tools/postprocess-style.php osm.xml

