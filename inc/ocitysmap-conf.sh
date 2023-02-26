#! /bin/sh

CONF=${INSTALLDIR:-/home/maposmatic}/.ocitysmap.conf
INCDIR=${INCDIR:-/vagrant/inc}

# header part is constant
# TODO: read from /vagrant/files/... instead?
cat <<EOF > $CONF
[datasource]
host=localhost
user=maposmatic
password=secret
dbname=gis

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

[rendering]
font-path=/usr/share/fonts/:/usr/local/share/fonts/
EOF


# extract list of available base style names
echo -n "available_stylesheets= " >> $CONF
grep --no-filename '\[.*\]' $INCDIR/styles/*.ini | sed -e 's/\[//g' -e 's/\]//g' | sort | paste -sd "," >> $CONF

# extract list of available overlay style names
echo -n "available_overlays= " >> $CONF
grep --no-filename '\[.*\]' $INCDIR/overlays/*.ini | sed -e 's/\[//g' -e 's/\]//g' | sort | paste -sd "," >> $CONF

# separator
echo >> $CONF

# copy all prepared style .ini sections
for style_ini in  $INCDIR/styles/*.ini $INCDIR/overlays/*.ini 
do
	sed -e 's|@STYLEDIR@|'$STYLEDIR'|g' -e 's|@INSTALLDIR@|'$INSTALLDIR'|g' < $style_ini >> $CONF
done

# cleanup
rm -f /root/.ocitysmap.conf
ln -s $CONF /root/.ocitysmap.conf

rm -f $VAGRANT/.ocitysmap.conf
ln -s $CONF $VAGRANT/.ocitysmap.conf


