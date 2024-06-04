#! /bin/bash

. /etc/profile.d/mapospatic.sh

cd $STYLEDIR/waymarkedtrails-backend

IMPORT_SIZE=60

REP_SERVICE=$(cat $INSTALLDIR/osm2pgsql-import/replication_url)

PROCESSES=2

echo "== Main DB Update =="
wmt-makedb db update || exit
echo

for style in hiking cycling mtb riding skating slopes # running
do
  echo "== $style DB Update =="
  wmt-makedb $style update || exit
  echo
done

psql planet -c "UPDATE waymarked_admin SET last_update=subq.minval FROM (SELECT MIN(status.date::timestamp WITHOUT TIME ZONE) as minval FROM status) subq"

