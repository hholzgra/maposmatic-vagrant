#! /bin/bash -e
#----------------------------------------------------
#
# Swiss OSM style
#
#----------------------------------------------------

pushd . > /dev/null

cd "$STYLEDIR"
git clone --quiet https://github.com/xyztobixyz/OSM-Swiss-Style
cd OSM-Swiss-Style

ln -s "$SHAPEFILE_DIR" data

sed -e '/\sname:/d' \
    -e 's/"type": "postgis"/"type": "postgis", "host": "gis-db", "user": "maposmatic", "password": "secret"/g' \
    < project.mml > osm.mml
carto --quiet --api "$MAPNIK_VERSION_FOR_CARTO" osm.mml > osm.xml
php "$FILEDIR"/tools/postprocess-style.php osm.xml

popd > /dev/null
