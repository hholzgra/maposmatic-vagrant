#! /bin/bash -e

. /etc/profile.d/mapospatic.sh

cd "$STYLEDIR"/waymarkedtrails-backend

OPTS=""
#OPTS="-S 5000"

FLAT_NODE_FILE="$INSTALLDIR"/import/waymarkedtrails/flat-nodes.dat

echo "== Main DB Update =="
wmt-makedb "$OPTS" -j "$(nproc)" -n "$FLAT_NODE_FILE" db update

for style in hiking cycling mtb riding skating slopes # running
do
  echo "== $style DB Update =="
  wmt-makedb -j "$(nproc)" -n "$FLAT_NODE_FILE" $style update
  echo
done

psql planet -c "UPDATE waymarked_admin SET last_update=subq.minval FROM (SELECT MIN(status.date::timestamp WITHOUT TIME ZONE) as minval FROM status) subq"

