#! /bin/bash -e
#----------------------------------------------------
#
# "Allotments" overlay
#
#----------------------------------------------------

pushd . > /dev/null

cd "$STYLEDIR"

git clone --quiet https://github.com/hholzgra/Mapnik-allotments.git

cp "$FILEDIR"/config-files/datasource-settings.xml.inc Mapnik-allotments/inc

popd > /dev/null
