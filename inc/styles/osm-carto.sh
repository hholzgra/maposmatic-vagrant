#----------------------------------------------------
#
# CartoOsm style sheet - the current OSM default style
#
#----------------------------------------------------

cd $STYLEDIR

git clone --quiet https://github.com/gravitystorm/openstreetmap-carto.git
cd openstreetmap-carto
git checkout --quiet v5.2.0

ln -s $SHAPEFILE_DIR data

sed '/\sname:/d' < project.mml > osm.mml
carto -a $(MAPNIK_VERSION_FOR_CARTO) --quiet osm.mml > osm.xml
php $FILEDIR/tools/postprocess-style.php osm.xml

# create color-reduced variant of generated style

php $FILEDIR/tools/make-style-monochrome.php

 
