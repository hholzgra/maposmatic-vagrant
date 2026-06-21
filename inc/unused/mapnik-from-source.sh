#! /bin/bash -e
#----------------------------------------------------
#
# Build Mapnik 2.3.x beta from source
#
# (Mapnik 2.2 has a bug that Ocitysmap runs into,
#  this is also fixed in Mapnik 3.0, but that also
#  changed the python API bindings ...
#
#----------------------------------------------------

pushd . > /dev/null

cd "$INSTALLDIR"

# build and install Mapik 2.3.x from git
# older Mapnik versions have a bug that leads to Cairo null pointer exceptions
# and Mapnik 3.0 doesn't have fully working python bindings yet
apt-get build-dep --quiet=2 --assume-yes python-mapnik
git clone --quiet https://github.com/mapnik/mapnik.git 
cd mapnik
git checkout --quiet v3.0.x

# configure, build, install
export SCONSFLAGS="-j 2"
python scons/scons.py configure CXX="g++" CC="gcc" SCONSFLAGS="$SCONSFLAGS"
python scons/scons.py
python scons/scons.py install
cd ..

popd > /dev/null
