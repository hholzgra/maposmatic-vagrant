#! /bin/bash -e

CONF=${INSTALLDIR:-/home/maposmatic}/.ocitysmap.conf
INCDIR=${INCDIR:-/vagrant/inc}

# header part is constant
# TODO: read from /vagrant/files/... instead?
cat <<EOF > $CONF
#
# MapOSMatic OCitysMap renderer configuration
#
EOF

echo >> $CONF
figlet "db settings" | sed -e 's/^/# /g' >> $CONF
echo >> $CONF
cat <<EOF >> $CONF
[datasource]
host=localhost
user=maposmatic
password=secret
dbname=gis
EOF

echo >> $CONF
figlet "paper sizes" | sed -e 's/^/# /g' >> $CONF
echo >> $CONF
cat <<EOF >> $CONF
[paper_sizes]
Din A4= 210x297
Din A3= 297x420
Din A2= 420x594
Din A1= 594x841
Din A0= 841x1189
2x A0= 1189x1682
US letter= 216x279

[multipage_paper_sizes]
Din A4= 210x297
US letter= 216x279
EOF

echo >> $CONF
figlet "render settings" | sed -e 's/^/# /g' >> $CONF
echo >> $CONF

cat <<EOF >> $CONF
[rendering]
font-path=/usr/share/fonts/:/usr/local/share/fonts/
EOF


# extract list of available base style names
echo "available_stylesheets=" >> $CONF
for name in $(grep --no-filename '\[.*\]' $INCDIR/styles/*.ini | sed -e 's/\[//g' -e 's/\]//g' | sort )
do
  echo "  $name," >> $CONF
done
echo >> $CONF

# extract list of available overlay style names
echo "available_overlays=" >> $CONF
for name in $(grep --no-filename '\[.*\]' $INCDIR/overlays/*.ini | sed -e 's/\[//g' -e 's/\]//g' | sort )
do
  echo "  $name," >> $CONF
done
echo >> $CONF


# copy all prepared style .ini sections
echo >> $CONF
figlet "base styles" | sed -e 's/^/# /g' >> $CONF
echo >> $CONF

# copy actual style definitions
for style_ini in  $INCDIR/styles/*.ini
do
	echo >> $CONF
	sed -e 's|@STYLEDIR@|'$STYLEDIR'|g' -e 's|@INSTALLDIR@|'$INSTALLDIR'|g' < $style_ini >> $CONF
done

# copy all prepared overlay .ini sections
echo >> $CONF
figlet "overlays" | sed -e 's/^/# /g' >> $CONF
echo >> $CONF

for style_ini in  $INCDIR/overlays/*.ini
do
	echo >> $CONF
	sed -e 's|@STYLEDIR@|'$STYLEDIR'|g' -e 's|@INSTALLDIR@|'$INSTALLDIR'|g' < $style_ini >> $CONF
done

# cleanup
rm -f /root/.ocitysmap.conf
ln -s $CONF /root/.ocitysmap.conf

rm -f $VAGRANT/.ocitysmap.conf
ln -s $CONF $VAGRANT/.ocitysmap.conf


