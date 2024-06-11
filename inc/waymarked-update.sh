#! /bin/bash

. /etc/profile.d/mapospatic.sh

cd $STYLEDIR/waymarkedtrails-backend

IMPORT_SIZE=60

REP_SERVICE=$(cat $INSTALLDIR/osm2pgsql-import/replication_url)

PROCESSES=2

OPTS=""
#OPTS="-S 5000"

FLAT_NODE_FILE=$INSTALLDIR/import/waymarkedtrails/flat-nodes.dat

echo "== Main DB Update =="
wmt-makedb $OPTS -j $(nproc) -n $FLAT_NODE_FILE db update
$OPTS || exit
echo

for style in hiking cycling mtb riding skating slopes # running
do
  echo "== $style DB Update =="
  wmt-makedb -j $(nproc) -n $FLAT_NODE_FILE $style update || exit
  echo
done

psql planet -c "UPDATE waymarked_admin SET last_update=subq.minval FROM (SELECT MIN(status.date::timestamp WITHOUT TIME ZONE) as minval FROM status) subq"

