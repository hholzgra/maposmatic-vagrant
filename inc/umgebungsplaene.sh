#! /bin/bash -e

cd $INSTALLDIR
git clone --quiet https://github.com/hholzgra/umgebungsplaene
cd umgebungsplaene
cp $FILEDIR/config-files/umgebungsplaene-config.php config.php
cd www
HOME=/root SUDO_USER=root SUDO_UID=0 SUDO_GID=0 npm install
cd ..
./i18n.py --compile-js
