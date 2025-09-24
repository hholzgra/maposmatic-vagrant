#----------------------------------------------------
#
# Import OSM data into database
#
#----------------------------------------------------

DBNAME=${DBNAME:-osm2pgsql_flex}
OSM_EXTRACT="${OSM_EXTRACT:-/vagrant/data.osm.pbf}"

STYLE_NAME="baumkarte"
STYLE_URL="https://github.com/rudzick/Mymapnik_openstreetmap-carto"
STYLE_BRANCH="master"

FILEDIR=${FILEDIR:-/vagrant/files}
STYLEDIR=${STYLEDIR:-/home/maposmatic/styles}
OSM2PGSQL=/usr/local/bin/osm2pgsql

STYLE_FILE=$STYLEDIR/$STYLE_NAME/openstreetmap-carto-flex.lua


if ! test -d $STYLEDIR/$STYLE_NAME
then
    cd $STYLEDIR

    git clone --quiet $STYLE_URL $STYLE_NAME
    cd $STYLE_NAME
    git checkout --quiet $STYLE_BRANCH
fi

IMPORTDIR=$INSTALLDIR/import/$DBNAME
mkdir -p $IMPORTDIR
chown maposmatic $IMPORTDIR
cd $IMPORTDIR

FLAT_NODE_FILE=osm2pgsql-nodes.dat

let CacheSize=$MemTotal/3072
echo "osm2pgsql cache size: $CacheSize"

# import data
time sudo --user=maposmatic $OSM2PGSQL \
    --create \
    --output=flex \
    --slim \
    --database=$DBNAME \
    --cache=$CacheSize \
    --number-processes=$(nproc) \
    --style=$STYLE_FILE \
    --flat-nodes=$FLAT_NODE_FILE \
    --disable-parallel-indexing \
    $OSM_EXTRACT

cd $STYLEDIR/$STYLE_NAME
mkdir -p data
chmod a+rwx data
sudo -u maposmatic ./scripts/get-external-data.py --database=$DBNAME

# build additional indes in parallel as per INSTALL.md
./scripts/indexes.py -0 | xargs -0 -P0 -I{} sudo -u maposmatic psql -d $DBNAME -c "{}"

sudo -u maposmatic psql $DBNAME < functions.sql

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
    for file in $FILEDIR/systemd/osm2pgsql-update-flex.*
    do
	sed $sed_opts < $file > /etc/systemd/system/$(basename $file)
    done
    chmod 644 /etc/systemd/system/osm2pgsql-update-flex.*
    systemctl daemon-reload
    systemctl enable osm2pgsql-update-flex.timer
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
