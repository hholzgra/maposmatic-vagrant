#! /bin/bash -e
#----------------------------------------------------
#
# SeaMap overlay - trying to mimic OpenSeaMap
#
# Original on https://github.com/hholzgra/mapnik-seamap-overlay
#
#----------------------------------------------------

pushd . > /dev/null

cd "$STYLEDIR"

git clone --quiet https://github.com/hholzgra/mapnik-seamap-overlay.git

popd > /dev/null
