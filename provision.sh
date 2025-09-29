#! /bin/bash

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
df -h /


#----------------------------------------------------
#
# use local Debian mirror on host if we have one
#
#----------------------------------------------------

if wget http://10.0.2.2/debian/pool/main/ --timeout=1 --tries=1 --quiet --output-file=/dev/null
then
	echo "deb http://10.0.2.2/debian bookworm main contrib non-free" > /etc/apt/sources.list
	apt-get update
fi



#----------------------------------------------------
#
# add "maposmatic" system user
#
#----------------------------------------------------
useradd --create-home maposmatic
usermod -a -G www-data maposmatic


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
mkdir -p $SHAPEFILE_DIR

STYLEDIR=$INSTALLDIR/styles
mkdir -p $STYLEDIR

# store memory size in KB in $MemTotal
export $(grep MemTotal /proc/meminfo | sed -e's/kB//' -e's/ //g' -e's/:/=/')

#----------------------------------------------------
#
# include local config file
#
#----------------------------------------------------

if test -f $VAGRANT/local-config.sh
then
    . $VAGRANT/local-config.sh
fi

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
	if test -r "$OSM_EXTRACT"
	then
		echo "Using $OSM_EXTRACT for OSM data import"
	else
		echo "$OSM_EXTRACT is not readable!"
		exit 3
	fi
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

# but keep "C" locale for now as locale changes only seem
# to have an effect on future login shells
export LANG=C.UTF-8
export LANGUAGE=C.UTF-8
export LC_ADDRESS=C.UTF-8
export LC_ALL=C.UTF-8
export LC_CTYPE=C.UTF-8
export LC_IDENTIFICATION=C.UTF-8
export LC_MEASUREMENT=C.UTF-8
export LC_MESSAGE=C.UTF-8
export LC_MONETARY=C.UTF-8
export LC_NAME=C.UTF-8
export LC_NUMERIC=C.UTF-8
export LC_PAPER=C.UTF-8
export LC_TELEPHONE=C.UTF-8
export LC_TIME=C.UTF-8

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

# pre-seed apt package cache
if test -d $CACHEDIR/apt
then
	cp -R $CACHEDIR/apt/* /var/cache/apt
fi

# sudo environment setup
. $INCDIR/sudoers.sh

# install local tools
. $INCDIR/install-tools.sh

# installing apt, pip and npm packages
. $INCDIR/install-packages.sh

PYTHON_VERSION=python$(python3 -c 'import sys; print("%d.%d" % (sys.version_info.major, sys.version_info.minor))')

# install all locales in the background
. $INCDIR/locales.sh

banner "shapefiles"
# install shapefiles
. $INCDIR/get-shapefiles.sh
# set up shapefile update job
cp $FILEDIR/systemd/shapefile-update.* /etc/systemd/system
systemctl daemon-reload


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

banner "db import - classic" 
export DBNAME=gis
. $INCDIR/osm2pgsql-import.sh

banner "db import - flex"
export DBNAME=osm2pgsql_flex
. $INCDIR/osm2pgsql-import-flex.sh

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

if test ${WITH_TILESERVER:=yes} = "yes"
then
    . $INCDIR/tileserver.sh
else
    echo "skipping"
fi


#----------------------------------------------------
#
# add weblate translation service
#
#----------------------------------------------------

banner "weblate"
if test ${WITH_WEBLATE:=yes} = "yes"
then
    . $INCDIR/weblate.sh
else
    echo "skipping"
fi

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

. $INCDIR/start-timer-jobs.sh

# write back compiler cache
cp -rn /root/.ccache $CACHEDIR

# write back apt package cache
rm -rf $CACHEDIR/apt
cp -R /var/cache/apt $CACHEDIR

