#! /bin/bash -e

DBNAME="${DBNAMES[classic]:-gis}"

DBDIR="$CACHEDIR"/postgres

mkdir -p "$DBDIR"

# create places table for replacing nominatim search
if ! test -f "$DBDIR"/places.sql.gz
then
	wget https://www.get-map.org/downloads/places.sql.gz -O "$DBDIR"/places.sql.gz
fi
zcat "$DBDIR"/places.sql.gz | sudo -u maposmatic psql "$DBNAME"

sudo -u maposmatic psql "$DBNAME" -c "CREATE INDEX place_osmid_idx ON public.place using btree(osm_id);"
sudo -u maposmatic psql "$DBNAME" -c "CREATE INDEX place_lower ON public.place USING btree (lower((name)::text));"

