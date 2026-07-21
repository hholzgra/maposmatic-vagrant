#! /bin/bash -e

pushd . > /dev/null

cd "$INSTALLDIR"

mkdir -p tools
cd tools

git clone --quiet https://github.com/openstreetmap/osm2pgsql.git

cd osm2pgsql

# build latest version first
mkdir _build
cd _build

cmake .. >/dev/null && make -j"$(nproc)" install >/dev/null

cd ..

# build version 1.11, too, as that was the last to support
# the legacy middle database format that some of the legacy
# map styles still rely on

git checkout --quiet 1.11.0
git submodule update --init --recursive >/dev/null 2>&1

mkdir _build_1.11
cd _build_1.11

cmake -DCMAKE_INSTALL_PREFIX=/opt/osm2pgsql-1.11 .. >/dev/null && make -j$(nproc) install >/dev/null

cd ..


popd > /dev/null
