#! /bin/bash -e
#----------------------------------------------------
#
# MapOSMatic Printable stylesheet
#
#----------------------------------------------------

pushd . > /dev/null

DBNAME="${DBNAMES[classic]:-gis}"

cd "$STYLEDIR"

# configure the actual stylesheet
cd ../ocitysmap/stylesheet/maposmatic-printable

# TODO db hardcoded?
"$FILEDIR"/tools/generate_xml.py \
       --dbname "$DBNAME" \
       --host 'localhost' \
       --user maposmatic \
       --port 5432 \
       --password 'secret' \
       --world_boundaries "$SHAPEFILE_DIR"/world_boundaries \
       --symbols "$INSTALLDIR"/ocitysmap/stylesheet/maposmatic-printable/symbols \
       > /dev/null

popd > /dev/null
