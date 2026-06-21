#! /bin/bash -e
#----------------------------------------------------
#
# Gaslight overlay
#
#----------------------------------------------------

pushd . > /dev/null

cd "$STYLEDIR"

git clone --quiet https://github.com/hholzgra/Mapnik-gaslight-overlay.git

popd > /dev/null
