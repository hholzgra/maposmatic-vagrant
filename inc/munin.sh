#! /bin/bash -e

pushd

FILEDIR=${FILEDIR:-/vagrant/files}

cd /etc/munin

cp "$FILEDIR"/munin/* plugins/

sed -i -e's/Require local/Require all granted/g' apache24.conf

systemctl restart apache2 munin-node

popd
