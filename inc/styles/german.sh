#! /bin/bash -e
#----------------------------------------------------
#
# German CartoOsm style sheet - the current openstreetmap.de style
#
#----------------------------------------------------

pushd . > /dev/null

DBNAME="${DBNAMES[classic]:-gis}"

cd "$STYLEDIR"

git clone --quiet https://github.com/giggls/openstreetmap-carto-de.git

cd openstreetmap-carto-de

latest_tag=$(php "$FILEDIR"/tools/get-latest-tag.php 'v.*-de\d+')

git checkout --quiet v4.24.0-de1

sed -i \
    -e 's/    type: "postgis"/    type: "postgis"\n    host: "gis-db"\n    user: "maposmatic"\n    password: "secret"/g' \
    -e's/dbname: "osm"/dbname: "'"$DBNAME"'"/' \
    project.mml
sed -i -e's/carto /carto -q /g' -e's/MAPNIK_API = .*/MAPNIK_API = '"$MAPNIK_VERSION_FOR_CARTO"'/g' Makefile
make

for a in *.xml
do
    php "$FILEDIR"/tools/postprocess-style.php "$a"
done

ln -s "$SHAPEFILE_DIR" data

popd > /dev/null
