#! /bin/bash -e

pushd . > /dev/null

cd "$INCDIR"

./osm2pgsql-import.sh

for type in styles overlays
do 
  for script in "$INCDIR"/"$type"/*.db
  do
     ( . "$script" )
  done
done

popd > /dev/null
