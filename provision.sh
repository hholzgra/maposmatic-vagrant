#! /bin/bash

df -h /

# For some strange reason I don't understand yet Vagrant
# seems to write "exit" to the provisioning scripts
# stdin stream. As this may confuse tools that optionally
# read from stdin (genenrate-xml.py in this case) we're
# draining stdin here as the first thing before doing
# anything else
if ! test -t 0
then
    cat > /dev/null
fi

#----------------------------------------------------
#
# the vagrant disksize plugin does not always manage 
# to resize the root file system so we do it here
# once more just in case
#
#----------------------------------------------------
growpart /dev/sda 1
resize2fs $(mount | grep "on / " | egrep -o "^[^ ]+")

#----------------------------------------------------
#
# putting some often used constants into variables
#
#----------------------------------------------------

VAGRANT=/vagrant
FILEDIR=$VAGRANT/files
INCDIR=$VAGRANT/inc

INSTALLDIR=/home/maposmatic

LOGDIR=$INSTALLDIR/logs
mkdir -p $LOGDIR
chmod a+rwx $LOGDIR

DATADIR=$INSTALLDIR/data
mkdir -p $DATADIR/rendered_maps $DATADIR/upload
chmod -R a+rwx $DATADIR

if touch $VAGRANT/can_write_here
then
	CACHEDIR=$VAGRANT/cache
	rm $VAGRANT/can_write_here
else
	mkdir -p /home/cache
	chmod a+rwx /home/cache
	CACHEDIR=/home/cache
fi

mkdir -p $CACHEDIR

SHAPEFILE_DIR=$INSTALLDIR/shapefiles
STYLEDIR=$INSTALLDIR/styles

# store memory size in KB in $MemTotal
export $(grep MemTotal /proc/meminfo | sed -e's/kB//' -e's/ //g' -e's/:/=/')

#----------------------------------------------------
#
# check for an OSM PBF extract to import
#
# if there are more than one: take the first one found
# if there are none: exit
#
#----------------------------------------------------

export OSM_EXTRACT=$(ls $VAGRANT/*.pbf | head -1)

if test -f "$OSM_EXTRACT"
then
	echo "Using $OSM_EXTRACT for OSM data import"
else
	echo "No OSM .pbf data file found for import!"
	exit 3
fi

#----------------------------------------------------
#
# Make variables used by included provision scripts
# available to VM users to be able to easily re-run scripts
#
#----------------------------------------------------

. $INCDIR/shell-profile.sh

#----------------------------------------------------
#
# Vagrant/Virtualbox environment preparations
# (not really Ocitysmap specific yet)
#
#----------------------------------------------------

# override language settings
locale-gen en_US.UTF-8
localedef --force --inputfile=en_US --charmap=UTF-8 en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ADDRESS=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_IDENTIFICATION=en_US.UTF-8
export LC_MEASUREMENT=en_US.UTF-8
export LC_MESSAGE=en_US.UTF-8
export LC_MONETARY=en_US.UTF-8
export LC_NAME=en_US.UTF-8
export LC_NUMERIC=en_US.UTF-8
export LC_PAPER=en_US.UTF-8
export LC_TELEPHONE=en_US.UTF-8
export LC_TIME=en_US.UTF-8

# silence curl and wget progress reports
# as these just flood the vagrant output in an unreadable way
echo "--silent" > /root/.curlrc
echo "quiet = on" > /root/.wgetrc

# pre-seed compiler cache
if test -d $CACHEDIR/.ccache/
then
    cp -rn $CACHEDIR/.ccache/ ~/
else
    mkdir -p ~/.ccache
fi

# sudo environment setup
. $INCDIR/sudoers.sh

# add "maposmatic" system user that will own the database and all locally installed stuff
useradd --create-home maposmatic
usermod -a -G www-data maposmatic

# install local tools
. $INCDIR/install-tools.sh

# installing apt, pip and npm packages
. $INCDIR/install-packages.sh

# install all locales in the background
. $INCDIR/locales.sh

# initial git configuration
. $INCDIR/git-setup.sh

# add host entry for gis-db
sed -ie 's/localhost/localhost gis-db/g' /etc/hosts

banner "db setup"
. $INCDIR/database-setup.sh

banner "places db"
. $INCDIR/places-database.sh

banner "db l10n"
. $INCDIR/from-source/mapnik-german-l10n.sh

banner "building osm2pgsql"
. $INCDIR/from-source/osm2pgsql-build.sh

banner "building phyghtmap" # needed by OpenTopoMap
. $INCDIR/from-source/phyghtmap.sh

banner "db import" 
. $INCDIR/osm2pgsql-import.sh

banner "get bounds"
python3 $INCDIR/data-bounds.py $INSTALLDIR/bounds $OSM_EXTRACT

banner "DEM setup"
. $INCDIR/elevation-data.sh

banner "renderer setup"
. $INCDIR/ocitysmap.sh



banner "shapefiles"
# install shapefiles
. $INCDIR/get-shapefiles.sh
# set up shapefile update job
cp $FILEDIR/systemd/shapefile-update.* /etc/systemd/system
systemctl daemon-reload


banner "styles"
. $INCDIR/styles.sh


#----------------------------------------------------
#
# Setting up Django fronted
#
#----------------------------------------------------

banner "django frontend"

. $INCDIR/apache-global-config.sh
. $INCDIR/maposmatic-frontend.sh


#----------------------------------------------------
#
# Setting up "Umgebungsplaene" alternative frontend
#
#----------------------------------------------------

banner "umgebungsplaene"

. $INCDIR/umgebungsplaene.sh

#----------------------------------------------------
#
# munin monitoring
#
#----------------------------------------------------

banner "munin"

. $INCDIR/munin.sh


#----------------------------------------------------
#
# some necessary security tweaks
#
#-----------------------------------------------------

banner "security"

. $INCDIR/security-quirks.sh


#----------------------------------------------------
#
# add simple tile server for offline operations
#
#----------------------------------------------------

banner "tileserver"

. $INCDIR/tileserver


#----------------------------------------------------
#
# tests
#
#-----------------------------------------------------

banner "running tests"

. $INCDIR/testing.sh

#----------------------------------------------------
#
# cleanup
#
#-----------------------------------------------------

banner "cleanup"

# write back compiler cache
cp -rn /root/.ccache $CACHEDIR

