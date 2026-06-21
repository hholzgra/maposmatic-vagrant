#! /bin/bash -e
#----------------------------------------------------
#
# Resiliency map overlay
#
#----------------------------------------------------

pushd . > /dev/null

cd "$STYLEDIR"

git clone --quiet https://github.com/hholzgra/Mapnik-resiliency-map

popd > /dev/null
