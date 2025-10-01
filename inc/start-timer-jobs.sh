#! /bin/bash

for timer in osm2pgsql-update osm2pgsql-udate-flex waymarked-update
do
	if test -f /etc/systemd/system/$timer.timer
	then
		systemctl start $timer.timer
	fi
done
