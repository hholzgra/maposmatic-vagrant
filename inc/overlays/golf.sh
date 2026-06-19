#! /bin/bash -e
#----------------------------------------------------
#
# Golf overlay style 
#
# Original on https://github.com/rweait/Mapnik-golf-overlay
#
#----------------------------------------------------

cd $STYLEDIR

git clone --quiet https://github.com/hholzgra/Mapnik-golf-overlay.git
cd Mapnik-golf-overlay
git checkout --quiet maposmatic

