#----------------------------------------------------
#
# Import OSM data into database
#
#----------------------------------------------------

FILEDIR=${FILEDIR:-/vagrant/files}
OSM_EXTRACT="${OSM_EXTRACT:-/vagrant/data.osm.pbf}"

DBNAME=osmcarto5

IMPORTDIR=$INSTALLDIR/import/osm2pgsql-v5
mkdir -p $IMPORTDIR
chown maposmatic $IMPORTDIR
cd $IMPORTDIR

STYLENAME=openstreetmap-carto-v5

STYLE_FILE=$STYLEDIR/$STYLENAME/openstreetmap-carto.style
LUA_FILE=$STYLEDIR/$STYLENAME/openstreetmap-carto.lua

FLAT_NODE_FILE=osm2pgsql-nodes.dat

let CacheSize=$MemTotal/3072
echo "osm2pgsql cache size: $CacheSize"

# import data
time sudo --user=maposmatic /usr/local/bin/osm2pgsql \
     --create \
     --slim \
     --database=$DBNAME \
     --merc \
     --hstore-all \
     --multi-geometry \
     --cache=$CacheSize \
     --number-processes=$(nproc) \
     --style=$STYLE_FILE \
     --tag-transform-script=$LUA_FILE \
     --flat-nodes=$FLAT_NODE_FILE \
     --disable-parallel-indexing \
     --keep-coastlines \
     $OSM_EXTRACT

# prepare for diff imports
REPLICATION_BASE_URL=$(osmium fileinfo -g 'header.option.osmosis_replication_base_url' "${OSM_EXTRACT}")
if ! test -z "$REPLICATION_BASE_URL"
then
    REPLICATION_SEQUENCE_NUMBER=$(pyosmium-get-changes --start-osm-data ${OSM_EXTRACT})
    REPLICATION_TIMESTAMP=$(osmium fileinfo -g 'header.option.osmosis_replication_timestamp' ${OSM_EXTRACT})

    echo -n $REPLICATION_BASE_URL > replication_url
    echo -n $REPLICATION_SEQUENCE_NUMBER > sequence_number

    sed_opts=""
    sed_opts+="-e s|@INSTALLDIR@|$INSTALLDIR|g "
    sed_opts+="-e s|@INCDIR@|$INCDIR|g "
    sed_opts+="-e s|@IMPORTDIR@|$IMPORTDIR|g "
    sed_opts+="-e s|@STYLEDIR@|$STYLEDIR|g "
    sed_opts+="-e s|@PYTHON_VERSION@|$PYTHON_VERSION|g "
    for file in $FILEDIR/systemd/osm2pgsql-update-v5.*
    do
	sed $sed_opts < $file > /etc/systemd/system/$(basename $file)
    done
    chmod 644 /etc/systemd/system/osm2pgsql-update-v5.*
    systemctl daemon-reload
    systemctl enable osm2pgsql-update-v5.timer
fi

if test -z "$REPLICATION_TIMESTAMP"
then
    # fallback: if no start date in header -> take timestamp from actual file contents
    REPLICATION_TIMESTAMP=$(osmium fileinfo -e -g data.timestamp.last $OSM_EXTRACT)
    if [[ $REPLICATION_TIMESTAMP =~ ^19[67] ]]
    then
        # 2nd fallback: if the date from the file contents comes out as the unix epoche
        # our last fallback is the files modification date	
	REPLICATION_TIMESTAMP=$(date --iso-8601=second --reference=$OSM_EXTRACT)
    fi
fi

sudo -u maposmatic psql $DBNAME -c "update maposmatic_admin set last_update='$REPLICATION_TIMESTAMP'"

cd $STYLEDIR/$STYLENAME/
./scripts/get-external-data.py
