#! /bin/bash -e
#----------------------------------------------------
#
# Belgian OSM style
#
#----------------------------------------------------

pushd . > /dev/null

cd "$STYLEDIR"
git clone --quiet https://github.com/jbelien/openstreetmap-carto-be
cd openstreetmap-carto-be

ln -s "$SHAPEFILE_DIR" data

patch -p1 < "$INCDIR"/styles/belgian.patch
carto --quiet --api "$MAPNIK_VERSION_FOR_CARTO" project.mml > belgian.xml

# TODO: still needed?
sed -i -e "s/craft,/tags->'craft',/g" \
    -i -e "s/industrial,/tags->'industrial',/g" \
    belgian.xml

php "$FILEDIR"/tools/postprocess-style.php belgian.xml

popd > /dev/null
