#! /bin/bash

. $INSTALLDIR/virtual-env/bin/activate

@INSTALLDIR@/ocitysmap/render.py "$@"


