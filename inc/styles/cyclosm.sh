#! /bin/bash

cd $STYLEDIR

git clone --quiet https://github.com/cyclosm/cyclosm-cartocss-style
cd cyclosm-cartocss-style

git checkout v0.7.1

# patch -p1 < $INCDIR/styles/cyclosm.patch

ln -s $SHAPEFILE_DIR data

cd dem
for hillshade in $STYLEDIR/OpenTopoMap/mapnik/dem/hillshade*
do
    ln -s $hillshade .
done
cd ..

		 
sed -e 's/"type": "postgis"/"type": "postgis", "host": "gis-db", "user": "maposmatic", "password": "secret"/g' \
    -e 's/dbname: "osm"/dbname: "gis"/g' \
    -e 's/http:\/\/osmdata.openstreetmap.de\/download\/simplified-land-polygons-complete-3857.zip/.\/data\/simplified-land-polygons-complete-3857\/simplified_land_polygons.shp/g' \
    -e 's/http:\/\/osmdata.openstreetmap.de\/download\/land-polygons-split-3857.zip/.\/data\/land-polygons-split-3857\/land_polygons.shp/g' \
    -e 's/layer~/layer::text~/g' \
    < project.mml > cyclosm.mml

carto -quiet --api $MAPNIK_VERSION_FOR_CARTO cyclosm.mml > cyclosm.xml
php $FILEDIR/tools/postprocess-style.php cyclosm.xml
