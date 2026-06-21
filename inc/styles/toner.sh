#! /bin/bash -e

pushd . > /dev/null

cd "$STYLEDIR"

git clone --quiet https://github.com/geofabrik/toner.git

cd toner

ln -s toner.mml project.mml

rm -rf data
ln -s "$SHAPEFILE_DIR" data

sed -e '/"name":/d' \
    -e 's/#  host:/  host:/g' -e 's/{{PGHOST}}/gis-db/g' \
    -e 's/#  user:/  user:/g' -e 's/{{PGUSER}}/maposmatic/g' \
    -e 's/#  password:/  password:/g' -e 's/{{PGPASSWORD}}/secret/g' \
    < toner.mml > osm.mml

carto --quiet --api "$MAPNIK_VERSION_FOR_CARTO" osm.mml > toner.xml

php "$FILEDIR"/tools/postprocess-style.php toner.xml

popd > /dev/null
