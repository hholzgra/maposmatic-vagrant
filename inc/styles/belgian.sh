#----------------------------------------------------
#
# Belgian OSM style
#
#----------------------------------------------------

cd $STYLEDIR
git clone --quiet https://github.com/jbelien/openstreetmap-carto-be
cd openstreetmap-carto-be

ln -s $SHAPEFILE_DIR data

git clone --quiet https://github.com/gravitystorm/openstreetmap-carto

cd openstreetmap-carto
git checkout --quiet v5.1.0
rm -rf .git
for file in $(find . -type f)
do
  dir=$(dirname $file)
  mkdir -p ../$dir
  if test ! -f ../$file
  then
    cp $file ../$file
  fi
done
cd ..
rm -rf openstreetmap-carto


sed -e '/\sname:/d' \
    -e 's/host:.*/host: "gis-db"/' \
    -e 's/user:.*/user: "maposmatic"\n    password: "secret"/' \
    -e 's/dbname:.*/dbname: "gis"/' \
< project.mml > osm.mml

carto -q -a $(MAPNIK_VERSION_FOR_CARTO) --quiet osm.mml > osm.xml
php $FILEDIR/tools/postprocess-style.php osm.xml

