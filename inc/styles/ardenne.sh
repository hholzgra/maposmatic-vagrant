#----------------------------------------------------
# OpenArdenneMap - Belgian topographic map style
#----------------------------------------------------

cd $STYLEDIR
git clone --quiet https://github.com/nobohan/OpenArdenneMap
cd OpenArdenneMap

mkdir contour
mkdir hillshade
mkdir downloads

cd downloads

wget http://opendata.champs-libres.be/beautiful-contour-belgium.zip
unzip beautiful-contour-belgium.zip
cd beautiful-contour-belgium
ogr2ogr -f "ESRI Shapefile" ../../contour beautiful-contour-belgium.gpkg
cd ..

wget http://opendata.champs-libres.be/hillshade_belgium.zip
unzip hillshade_belgium.zip
mv dem*hillshade*.tif ../hillshade/hillshade.tif

cd ../contour/
mmv 'beautiful-contour-belgium.*' 'contours_3857.#1'

cd ../osm2pgsql

sed -i \
    -e 's/"dbname": "osmpg_db"/"dbname": "gis"/g' \
    -e 's/"type": "postgis"/"type": "postgis", "host": "gis-db", "user": "maposmatic", "password": "secret"/g' \
    -e 's|/mnt/tera/ChampsLibres/Projets/OSM/CyclOSM/hillshade/data/dem_be_10x10_hillshade_semi_transparent_3857.tif|../hillshade/hillshade.tif|g' \
    project.mml

carto --quiet --api $MAPNIK_VERSION_FOR_CARTO project.mml > OpenArdenneMap.xml

php $FILEDIR/tools/postprocess-style.php OpenArdenneMap.xml

