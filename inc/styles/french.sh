#! /bin/bash -e

pushd . > /dev/null

DBNAME="${DBNAMES[classic]:-gis}"

cd "$STYLEDIR"

git clone --quiet https://github.com/cquest/osmfr-cartocss.git
cd osmfr-cartocss
git checkout --quiet v2.8.0

ln -s "$SHAPEFILE_DIR" data

sed -e '/\sname:/d' \
    -e 's/        "type": "postgis",/        "type": "postgis",\n        "host": "gis-db",\n        "user": "maposmatic",\n        "password": "secret",/g' \
    -e 's/dbname:.*/dbname: "'"$DBNAME"'"/' \
    < project.mml > osm.mml
carto --quiet --api "$MAPNIK_VERSION_FOR_CARTO" osm.mml > osm.xml

popd > /dev/null
