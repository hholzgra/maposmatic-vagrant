#! /bin/bash -e

pushd . > /dev/null

cd "$STYLEDIR"

mkdir empty
cd empty
cp "$FILEDIR"/styles/empty.xml .

popd > /dev/null
