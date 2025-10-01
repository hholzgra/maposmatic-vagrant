#----------------------------------------------------
#
# Set up PostgreSQL and PostGIS
#
#----------------------------------------------------

# config tweaks

# Keep for OS some free memory to prevent killing PostgreSQL by Out-Of-Memory Killer
let Mem_OS=100000
let Mem_DB=$MemTotal-$Mem_OS
let Mem_1_5=$Mem_DB/5
let Mem_1_10=$Mem_DB/10

pg_confdir=/etc/postgresql/$(pg_conftool --short show cluster_name)/conf.d

sed -e"s/@Mem_1_5@/$Mem_1_5/g" -e"s/@Mem_1_10@/$Mem_1_10/g" < $FILEDIR/config-files/postgresql-extra.conf > $pg_confdir/postgresql-extra.conf

systemctl restart postgresql

# add "gis" database users
sudo --user=postgres createuser --superuser --no-createdb --no-createrole maposmatic
sudo -u postgres createuser -g maposmatic root
sudo -u postgres createuser -g maposmatic vagrant
sudo -u postgres createuser -g maposmatic www-data
sudo -u postgres createuser -g maposmatic tirex

# set password for gis database user
sudo --user=maposmatic psql --dbname=postgres --command="ALTER USER maposmatic WITH PASSWORD 'secret';"

for DATABASE in gis osm2pgsql_flex
do
  # creade databases for osm2pgsql import
  sudo --user=postgres createdb --encoding=UTF8 --locale=en_US.UTF-8 --template=template0 --owner=maposmatic $DATABASE

  # set up PostGIS for osm2pgsql database
  sudo --user=postgres psql --dbname=$DATABASE --command="CREATE EXTENSION postgis"
  sudo --user=postgres psql --dbname=$DATABASE --command="ALTER TABLE geometry_columns OWNER TO maposmatic"
  sudo --user=postgres psql --dbname=$DATABASE --command="ALTER TABLE spatial_ref_sys OWNER TO maposmatic"
  sudo --user=postgres psql --dbname=$DATABASE --command="CREATE EXTENSION postgis_sfcgal"

  # enable hstore extension
  sudo --user=postgres psql --dbname=$DATABASE --command="CREATE EXTENSION hstore"

  # set up maposmatic admin table
  sudo --user=maposmatic psql --dbname=$DATABASE --command="CREATE TABLE maposmatic_admin (last_update timestamp)"
  sudo --user=maposmatic psql --dbname=$DATABASE --command="INSERT INTO maposmatic_admin VALUES ('1970-01-01 00:00:00')"
done

# creade database for maposmatic django frontend
sudo --user=postgres createdb --encoding=UTF8 --locale=en_US.UTF-8 --template=template0 --owner=maposmatic maposmatic

# enable dblink extension
sudo --user=maposmatic psql --dbname=maposmatic --command="CREATE EXTENSION dblink"

