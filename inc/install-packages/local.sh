#! /bin/bash -e

FILEDIR=${FILEDIR:-/vagrant/files}

pushd $FILEDIR/install-local > /dev/null

for deb in *.deb
do
  apt-get install -y $deb
done

for whl in *.whl
do
  pip3 install -y $whl
done

popd > /dev/null
