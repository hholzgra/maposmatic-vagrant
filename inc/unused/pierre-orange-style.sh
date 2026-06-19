#! /bin/bash -e
#----------------------------------------------------
#
# MapOSMatic Printable stylesheet
#
#----------------------------------------------------

cd $STYLEDIR

# we need to add the MapOSMatic specific
# symbols to the "old" MapnikOSM symbol set
cp $INSTALLDIR/ocitysmap/stylesheet/maposmatic-printable/symbols/* mapnik2-osm/symbols/

# configure the actual stylesheet
cd $INSTALLDIR/ocitysmap/stylesheet/pierre-orange

$FILEDIR/tools/generate_xml.py \
       --dbname gis \
       --host 'localhost' \
       --user maposmatic \
       --port 5432 \
       --password 'secret' \
       --world_boundaries $SHAPEFILE_DIR/world_boundaries \
       --symbols $INSTALLDIR/ocitysmap/stylesheet/maposmatic-printable/symbols

