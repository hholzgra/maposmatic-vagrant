#! /bin/bash -e

DBDIR=$CACHEDIR/postgres

mkdir -p $DBDIR

# create places table for replacing nominatim search
if ! test -f $DBDIR/places.sql.gz
then
	wget https://www.get-map.org/downloads/places.sql.gz -O $DBDIR/places.sql.gz
fi
zcat $DBDIR/places.sql.gz | sudo -u maposmatic psql gis 

sudo -u maposmatic psql gis -c "CREATE INDEX place_osmid_idx ON public.place using btree(osm_id);"
sudo -u maposmatic psql gis -c "CREATE INDEX place_lower ON public.place USING btree (lower((name)::text));"

