#! /bin/bash -e

pushd . > /dev/null

cd "$STYLEDIR"

git clone --quiet https://github.com/hholzgra/veloroad.git
cd veloroad

mkdir -p data
ln -s "$SHAPEFILE_DIR"/water-polygons-split-3857 data
ln -s "$SHAPEFILE_DIR"/gmted25 data/gmted

sed -e '/"name":/d' \
    -e 's/"type": "postgis"/"type": "postgis", "host": "gis-db", "user": "maposmatic", "password": "secret"/g' \
    < project.mml > osm.mml
carto --quiet --api "$MAPNIK_VERSION_FOR_CARTO" osm.mml > veloroad.xml

popd > /dev/null
