#! /bin/bash -e

pushd . > /dev/null

cd "$STYLEDIR"

mkdir contour-overlay
cd contour-overlay
cp "$FILEDIR"/styles/contour*xml .

popd > /dev/null
