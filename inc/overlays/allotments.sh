#! /bin/bash -e
#----------------------------------------------------
#
# "Allotments" overlay
#
#----------------------------------------------------

cd $STYLEDIR

git clone --quiet https://github.com/hholzgra/Mapnik-allotments.git

cp $FILEDIR/config-files/datasource-settings.xml.inc Mapnik-allotments/inc

