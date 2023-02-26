#----------------------------------------------------
#
# Set up PostgreSQL and PostGIS
#
#----------------------------------------------------

# config tweaks
# TODO how to auto-detect correct conf include dir?
# Keep for OS some free memory to prevent killing PostgreSQL by Out-Of-Memory Killer
let Mem_OS=100000
let Mem_DB=$MemTotal-$Mem_OS
let Mem_1_5=$Mem_DB/5
let Mem_1_10=$Mem_DB/10
sed -e"s/#Mem_1_5#/$Mem_1_5/g" -e"s/#Mem_1_10#/$Mem_1_10/g" < $FILEDIR/config-files/postgresql-extra.conf >/etc/postgresql/15/main/conf.d/postgresql-extra.conf
systemctl restart postgresql

# add "gis" database users
usermod -a -G vagrant postgres 
sudo --user=postgres createuser --superuser --no-createdb --no-createrole maposmatic
sudo -u postgres createuser -g maposmatic root
sudo -u postgres createuser -g maposmatic vagrant
sudo -u postgres createuser -g maposmatic www-data


# creade database for osm2pgsql import
sudo --user=postgres createdb --encoding=UTF8 --locale=en_US.UTF-8 --template=template0 --owner=maposmatic gis

# set up PostGIS for osm2pgsql database
sudo --user=postgres psql --dbname=gis --command="CREATE EXTENSION postgis"
sudo --user=postgres psql --dbname=gis --command="ALTER TABLE geometry_columns OWNER TO maposmatic"
sudo --user=postgres psql --dbname=gis --command="ALTER TABLE spatial_ref_sys OWNER TO maposmatic"
sudo --user=postgres psql --dbname=gis --command="CREATE EXTENSION postgis_sfcgal"

# enable hstore extension
sudo --user=postgres psql --dbname=gis --command="CREATE EXTENSION hstore"

# set up maposmatic admin table
sudo --user=maposmatic psql --dbname=gis --command="CREATE TABLE maposmatic_admin (last_update timestamp)"
sudo --user=maposmatic psql --dbname=gis --command="INSERT INTO maposmatic_admin VALUES ('1970-01-01 00:00:00')"

# creade database for maposmatic
sudo --user=postgres createdb --encoding=UTF8 --locale=en_US.UTF-8 --template=template0 --owner=maposmatic maposmatic

# set password for gis database user
sudo --user=maposmatic psql --dbname=postgres --command="ALTER USER maposmatic WITH PASSWORD 'secret';"

