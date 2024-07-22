#! /bin/bash

deactivate 2>/dev/null
. $INSTALLDIR/bin/activate

cd $VAGRANT/test
chmod a+w .
rm -f test-* thumbnails/test-*
./run-tests.sh

