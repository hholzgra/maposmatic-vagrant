#! /bin/bash

FILE="${OSM_EXTRACT:-/vagrant/data.osm.pbf}"
REPLICATION_BASE_URL="$(osmium fileinfo -g 'header.option.osmosis_replication_base_url' "${FILE}")"

if test -z "$REPLICATION_BASE_URL"
then
	REPLICATION_BASE_OPTION=''
else
	REPLICATION_BASE_OPTION="-r $REPLICATION_BASE_URL"
fi

cd $STYLEDIR/


git clone  https://github.com/waymarkedtrails/waymarkedtrails-backend

cd waymarkedtrails-backend

. $INSTALLDIR/virtual-env/bin/activate

pip3 install  git+https://github.com/waymarkedtrails/osgende@master \
	      git+https://github.com/waymarkedtrails/waymarkedtrails-shields@master
pip3 install .

mkdir symbols
chown maposmatic symbols

for style in *.xml
do
    sed -i \
	-e 's|<Parameter name="type">postgis</Parameter>|<Parameter name="type">postgis</Parameter><Parameter name="host">gis-db</Parameter><Parameter name="user">maposmatic</Parameter><Parameter name="password">secret</Parameter>|g' \
	$style
done

if ! test -z "$REPLICATION_BASE_URL"
then
    echo ${REPLICATION_BASE_URL} > "${OSMOSIS_DIFFIMPORT}/baseurl.txt"

    sed_opts="-e s|@INSTALLDIR@|$INSTALLDIR|g"
    sed_opts="$sed_opts -e s|@INCDIR@|$INCDIR|g"
    for file in $FILEDIR/systemd/waymarked-update.*
    do
	sed $sed_opts < $file > /etc/systemd/system/$(basename $file)
    done

    chmod 644 /etc/systemd/system/waymarked-update.*
    systemctl daemon-reload
    systemctl enable waymarked-update.timer
    systemctl start waymarked-update.timer
fi

