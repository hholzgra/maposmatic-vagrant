#! /bin/bash -e

pushd

#----------------------------------------------------
#
# Fetch OCitysMap from GitHub and configure it
#
#----------------------------------------------------

# install latest ocitysmap from git
cd "$INSTALLDIR"
git clone --quiet https://github.com/hholzgra/ocitysmap.git
cd ocitysmap
if test -n "$OCITYSMAP_BRANCH"
then
  git checkout --quiet "$OCITYSMAP_BRANCH"
fi

chown -R vagrant .
git remote add pushme git@github.com:hholzgra/ocitysmap.git

# fetch submodules so that all icon sets are actually installed
git submodule init
git submodule update

# compile all translation files
./i18n.py --compile-mo

# make sure the cmdline render script is executable
chmod a+x render.py

# install the command line wrapper script in $PATH
sed -e "s|@INSTALLDIR@|$INSTALLDIR|g" <  "$FILEDIR/config-files/ocitysmap-command.sh" > /usr/local/bin/ocitysmap
chmod a+x /usr/local/bin/ocitysmap

popd
