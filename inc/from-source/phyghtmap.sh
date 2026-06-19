#! /bin/bash -e

pushd

cd "$INSTALLDIR"

mkdir -p tools
cd tools

wget http://katze.tfiu.de/projects/phyghtmap/phyghtmap_2.21.orig.tar.gz
tar -xvf phyghtmap_2.21.orig.tar.gz
cd phyghtmap-2.21
python3 setup.py install

popd
