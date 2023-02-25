#----------------------------------------------------
#
# Swiss OSM style
#
#----------------------------------------------------

cd $STYLEDIR
git clone --quiet https://github.com/xyztobixyz/OSM-Swiss-Style
cd OSM-Swiss-Style

ln -s $SHAPEFILE_DIR data

sed '/\sname:/d' < project.mml > osm.mml
carto -a $(MAPNIK_VERSION_FOR_CARTO) --quiet osm.mml > osm.xml
php $FILEDIR/tools/postprocess-style.php osm.xml

