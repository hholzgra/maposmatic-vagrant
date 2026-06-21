#! /bin/bash -e
#----------------------------------------------------
#
# Health Overlay style
#
# Original on https://github.com/rweait/Mapnik-health-overlay
#
#----------------------------------------------------

pushd . > /dev/null

cd "$STYLEDIR"

git clone --quiet https://github.com/hholzgra/Mapnik-health-overlay.git

cd Mapnik-health-overlay
cp "$FILEDIR"/config-files/datasource-settings.xml.inc inc

popd > /dev/null
