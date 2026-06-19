#! /bin/bash -e
#----------------------------------------------------
#
# MapOSMatic Printable stylesheet
#
#----------------------------------------------------

cd $STYLEDIR

# configure the actual stylesheet
cd ../ocitysmap/stylesheet/maposmatic-printable

$FILEDIR/tools/generate_xml.py \
       --dbname gis \
       --host 'localhost' \
       --user maposmatic \
       --port 5432 \
       --password 'secret' \
       --world_boundaries $SHAPEFILE_DIR/world_boundaries \
       --symbols $INSTALLDIR/ocitysmap/stylesheet/maposmatic-printable/symbols \
       > /dev/null
