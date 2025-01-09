#! /bin/bash

INCDIR=${INCDIR:-/vagrant/inc}

STYLEDIR=${STYLEDIR:-$INSTALLDIR/styles}

MAPNIK_VERSION_FOR_CARTO=3.0.32

#----------------------------------------------------
#
# Set up various stylesheets 
#
#----------------------------------------------------

mkdir -p $STYLEDIR

cd $INCDIR

# process all base styles
for style in ./styles/*.sh
do
  base=$(basename $style .sh)
  banner $base" style"
  ( . $style )
  if test -f ./styles/$base.db
  then
    echo "running $base.db"
    ( . ./styles/$base.db )
  else
    echo "no $base.db script"
  fi
done

# process all overlay styles
for overlay in ./overlays/*.sh
do
  base=$(basename $overlay .sh)
  banner $base" overlay"
  ( . $overlay )
  if test -f ./overlays/$base.db
  then
    ( . ./overlays/$base.db )
  fi
done

#----------------------------------------------------
#
# Postprocess all generated style sheets
#
#----------------------------------------------------

banner "postprocessing styles"

# with new Proj version in Debian 12 old style
# projection strings are no longer supported
for file in $(find $STYLEDIR -name '*.xml*') $(find $INSTALLDIR/ocitysmap/stylesheet/ -name '*.xml*')
do
  sed -i -e 's/+init=//g' $file
done

# generate the ocitysmap config file covering all styles
. ocitysmap-conf.sh

