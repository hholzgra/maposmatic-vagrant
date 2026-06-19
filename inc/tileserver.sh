#! /bin/bash -e

cat $FILEDIR/config-files/renderd.conf >> /etc/renderd.conf

cp $FILEDIR/config-files/a2-renderd-module.conf /etc/apache2/conf-available/renderd.conf
a2enconf renderd

mkdir -p /var/lib/mod_tile/osmcarto
chown _renderd /var/lib/mod_tile/osmcarto

sudo -u postgres createuser -g maposmatic _renderd

systemctl restart renderd apache2
