#! /bin/bash

systemctl start osm2pgsql-update.timer
systemctl start osm2pgsql-update-flex.timer
systemctl start waymarked-update.timer
