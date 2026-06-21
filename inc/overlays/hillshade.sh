#! /bin/bash -e

pushd . > /dev/null

mkdir -p "$STYLEDIR"/hillshade-overlay
cd "$STYLEDIR"/hillshade-overlay

cp "$FILEDIR"/styles/hillshade.xml .
ln -s "$INSTALLDIR"/elevation-data/dem .

popd > /dev/null
