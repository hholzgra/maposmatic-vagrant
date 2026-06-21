#! /bin/bash -e
#----------------------------------------------------
#
# "Schwarzkarte" overlay, showing building polygons only
#
#----------------------------------------------------

pushd . > /dev/null

cd "$STYLEDIR"

git clone --quiet https://github.com/hholzgra/Mapnik-schwarzkarte-overlay.git

popd > /dev/null
