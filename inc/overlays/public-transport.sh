#! /bin/bash -e

cd $STYLEDIR

git clone https://github.com/giggls/openptmap

cd openptmap

sed -ie 's/>osm</>gis</g' datasource-settings.xml.inc
echo '<Parameter name="host">gis-db</Parameter>' >> datasource-settings.xml.inc
echo '<Parameter name="user">maposmatic</Parameter>' >> datasource-settings.xml.inc
echo '<Parameter name="password">secret</Parameter>' >> datasource-settings.xml.inc

