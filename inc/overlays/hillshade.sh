#! /bin/bash

mkdir -p $STYLEDIR/hillshade-overlay
cd $STYLEDIR/hillshade-overlay

cp $FILEDIR/styles/hillshade.xml .
ln -s /home/maposmatic/elevation-data/dem .
