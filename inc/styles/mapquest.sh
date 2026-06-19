#! /bin/bash -e
#----------------------------------------------------
#
# Mapquest EU Stylesheet
#
#----------------------------------------------------

cd $STYLEDIR

# fetch current stylesheet version
git clone --quiet https://github.com/hholzgra/MapQuest-Mapnik-Style.git

cd MapQuest-Mapnik-Style

# fetch additional files required by this style
ln -s $SHAPEFILE_DIR/world_boundaries/ .

# generate stylesheet XML
$FILEDIR/tools/generate_xml.py \
       --inc mapquest_inc \
       --symbols mapquest_symbols \
       --dbname gis \
       --host 'localhost' \
       --user maposmatic \
       --port 5432 \
       --password secret \
       > /dev/null

$FILEDIR/tools/generate_xml.py \
       --inc hybrid_inc \
       --symbols hybrid_symbols \
       --dbname gis \
       --host 'localhost' \
       --user maposmatic \
       --port 5432 \
       --password secret \
       > /dev/null

