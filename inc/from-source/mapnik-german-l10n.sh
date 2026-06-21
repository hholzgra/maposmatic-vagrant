#! /bin/bash -e

pushd . > /dev/null

#-------------------------------------------------------
#
# contrib extensions required by osml10n extension
#
#--------------------------------------------------------

sudo --user=maposmatic psql --dbname=gis --command="CREATE EXTENSION fuzzystrmatch"
sudo --user=maposmatic psql --dbname=gis --command="CREATE EXTENSION unaccent"

#----------------------------------------------------------
#
# osml10n extension for PostgreSQL required by german style
#
#----------------------------------------------------------

cd "$INSTALLDIR"

mkdir -p tools
cd tools

git clone --quiet https://github.com/hholzgra/mapnik-german-l10n.git
cd mapnik-german-l10n
for target in README INSTALL
do
	make $target 2>/dev/null
	make $target.html 2>/dev/null
done
make install
sudo --user=maposmatic psql --dbname=gis --command="CREATE EXTENSION osml10n"

popd > /dev/null
