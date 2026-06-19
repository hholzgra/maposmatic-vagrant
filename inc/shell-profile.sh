#! /bin/bash -e

#
# make variables used in provisioning scripts
# available to users inside the VM so that
# the scripts can easily be re-run in there
#

outfile=/etc/profile.d/mapospatic.sh

echo "#! /bin/sh" > $outfile

vars=""

vars+="FILEDIR "
vars+="INCDIR "
vars+="INSTALLDIR "
vars+="CACHEDIR "
vars+="OSM_EXTRACT "
vars+="SHAPEFILE_DIR "
vars+="STYLEDIR "
vars+="MemTotal "

for var in $vars
do
    echo "export $var=${!var}" >> $outfile
done

#
# enable the maposmatic/ocitysmap virtual environment
#
echo ". $INSTALLDIR/bin/activate" >> $outfile

#
# prevent "message of the day" to be shown on vagrant login
#

touch /home/vagrant/.hushlogin; chown vagrant /home/vagrant/.hushlogin
