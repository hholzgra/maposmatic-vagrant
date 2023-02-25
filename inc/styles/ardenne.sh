#----------------------------------------------------
# OpenArdenneMap - Belgian topographic map style
#----------------------------------------------------

cd $STYLEDIR
git clone --quiet https://github.com/nobohan/OpenArdenneMap
cd OpenArdenneMap

mkdir contour

mkdir downloads
cd downloads
wget http://opendata.champs-libres.be/beautiful-contour-belgium.zip
unzip beautiful-contour-belgium.zip
cd beautiful-contour-belgium
ogr2ogr -f "ESRI Shapefile" ../../contour beautiful-contour-belgium.gpkg

cd ../../contour/
mmv 'beautiful-contour-belgium.*' 'beautiful_contour_belgium.#1'

cd ../osm2pgsql

sed -i -e 's/"osmpg_db"/"gis"/g' project.mml

carto -a $MAPNIK_VERSION_FOR_CARTO --quiet project.mml > OpenArdenneMap.xml

php $FILEDIR/tools/postprocess-style.php OpenArdenneMap.xml

