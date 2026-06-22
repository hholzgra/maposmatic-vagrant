#! /bin/bash -e

pushd . > /dev/null

DBNAME="${DBNAMES[classic]:-gis}"

cd "$STYLEDIR"

git clone https://github.com/giggls/openptmap

cd openptmap

sed -ie 's/>osm</>'"$DBNAME"'</g' datasource-settings.xml.inc
{
  echo '<Parameter name="host">gis-db</Parameter>'
  echo '<Parameter name="user">maposmatic</Parameter>'
  echo '<Parameter name="password">secret</Parameter>'
} >> datasource-settings.xml.inc

popd > /dev/null
