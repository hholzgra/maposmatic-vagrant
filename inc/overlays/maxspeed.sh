#! /bin/bash -e

#----------------------------------------------------
#
# Maxspeed overlay
#
#----------------------------------------------------

pushd . > /dev/null

cd "$STYLEDIR"

git clone --quiet https://github.com/hholzgra/Mapnik-maxspeed-overlay.git

popd > /dev/null
