#! /bin/bash -e

cd $INCDIR

./osm2pgsql-import.sh

for type in styles overlays
do 
  for script in $INCDIR/$type/*.db
  do
     ( . $script )
  done
done
