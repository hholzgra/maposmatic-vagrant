#! /bin/bash

cd $STYLEDIR

git clone https://github.com/hholzgra/oomap

cd oomap/

git remote add upstream https://github.com/oobrien/oomap

git checkout maposmatic

cd maptiler/

for file in $FILEDIR/styles/oomap/*
do
	sed -e "s|@STYLEDIR@|$STYLEDIR|g" < $file > styles/inc/$(basename $file)
done

ln -s $SHAPEFILE_DIR .
