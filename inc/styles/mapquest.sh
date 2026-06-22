#! /bin/bash -e
#----------------------------------------------------
#
# Mapquest EU Stylesheet
#
#----------------------------------------------------

pushd . > /dev/null

DBNAME="${DBNAMES[classic]:-gis}"

cd "$STYLEDIR"

# fetch current stylesheet version
git clone --quiet https://github.com/hholzgra/MapQuest-Mapnik-Style.git

cd MapQuest-Mapnik-Style

# fetch additional files required by this style
ln -s "$SHAPEFILE_DIR"/world_boundaries/ .

# generate stylesheet XML
# TODO DB hardcoded?
"$FILEDIR"/tools/generate_xml.py \
       --inc mapquest_inc \
       --symbols mapquest_symbols \
       --dbname "$DBNAME" \
       --host 'gis-db' \
       --user maposmatic \
       --port 5432 \
       --password secret \
       > /dev/null

"$FILEDIR"/tools/generate_xml.py \
       --inc hybrid_inc \
       --symbols hybrid_symbols \
       --dbname "$DBNAME" \
       --host 'localhost' \
       --user maposmatic \
       --port 5432 \
       --password secret \
       > /dev/null

popd > /dev/null
