#! /bin/bash

cd $INSTALLDIR/osm2pgsql-import

STATEFILE=sequence_number
DIFFFILE=pyosmium.osc
BASE_URL=$(cat replication_url)

if ! test -f $STATEFILE
then
    echo "No OSM import state file found"
    exit 3
fi

cp $STATEFILE $STATEFILE.old

rm -f $DIFFFILE
if ! pyosmium-get-changes -v --size 10 --sequence-file $STATEFILE --outfile $DIFFFILE  --server=$BASE_URL
then
    echo "getting changes failed"
    mv $STATEFILE.old $STATEFILE
    rm -f $DIFFFILE
    exit 3
fi

if sudo -u maposmatic /usr/bin/osm2pgsql \
     --append \
     --slim \
     --database=gis \
     --merc \
     --hstore-all \
     --cache=1000 \
     --number-processes=2 \
     --style=hstore-only.style \
     --tag-transform-script=openstreetmap-carto.lua \
     --prefix=planet_osm_hstore \
     --flat-nodes=$INSTALLDIR/osm2pgsql-import/osm2pgsql-nodes.dat \
     $DIFFFILE 
then
    timestamp=$(osmium fileinfo --extended --no-progress --get data.timestamp.last $DIFFFILE)
    sudo -u maposmatic psql gis -c "update maposmatic_admin set last_update='$timestamp'"
    rm -f $DIFFFILE
else
    echo "OSM data import failed"
    rm -f $DIFFFILE
    mv $STATEFILE.old $STATEFILE
    exit 3
fi

