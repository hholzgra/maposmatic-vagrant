#----------------------------------------------------
#
# CartoOsm style sheet - the current OSM default style
#
#----------------------------------------------------

cd $STYLEDIR

git clone --quiet https://github.com/rudzick/Mymapnik_openstreetmap-carto baumkarte
cd baumkarte

ln -s $SHAPEFILE_DIR data

patch -p1 < $INCDIR/styles/baumkarte.patch
carto --quiet --api $MAPNIK_VERSION_FOR_CARTO project.mml > baumkarte.xml
php $FILEDIR/tools/postprocess-style.php baumkarte.xml

sudo -u maposmatic psql osmcarto_flex < ./Server_Update/tree_species.sql

