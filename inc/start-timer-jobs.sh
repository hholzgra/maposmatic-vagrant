#! /bin/bash

systemctl start osm2pgsql-update.timer
systemctl start osm2pgsql-update-v5.timer
systemctl start waymarked-update.timer
