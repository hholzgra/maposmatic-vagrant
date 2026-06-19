#! /bin/bash -e

useradd --create-home --home-dir=$INSTALLDIR/weblate weblate
usermod -a -G www-data weblate

sudo --user=postgres createuser --role=maposmatic weblate
sudo --user=postgres createdb --encoding=UTF8 --locale=en_US.UTF-8 --template=template0 --owner=weblate weblate
sudo --user=postgres psql --dbname=postgres --command="ALTER USER weblate WITH PASSWORD 'secret';"


cd $INSTALLDIR/weblate

deactivate 2>/dev/null
virtualenv .
. bin/activate

pip install "Weblate[all]"==4.14.1

PYTHON_DIR="$PWD/lib/$PYTHON_VERSION"
PYTHON_PKG_DIR="$PYTHON_DIR/site-packages"
WEBLATE_PKG_DIR="$PYTHON_PKG_DIR/weblate"

(cd $WEBLATE_PKG_DIR; cp settings_example.py settings.py; patch -p0 < /vagrant/files/config-files/weblate-settings.patch)

sudo -u weblate psql weblate < /vagrant/weblate/weblate.sql

weblate migrate
weblate createadmin --username admin --password secret --email webmaster@get-map.org 
weblate collectstatic
# weblate compress


chown -R weblate .

mkdir -p data/cache
chown -R weblate:www-data data
chmod -R ug+rwx data

mkdir -p logs
chown weblate:www-data logs
chmod ug+rwx logs

# set up celery systemD service
# see also: https://docs.weblate.org/en/latest/admin/install.html#running-celery-as-system-service
sed -e"s|/home/weblate/|$INSTALLDIR/weblate/|g" \
    < $WEBLATE_PKG_DIR/examples/celery-weblate.service \
    > /etc/systemd/system/celery-weblate.service

sed -e"s|/home/weblate/weblate-env/|/home/maposmatic/weblate/|g" \
    -e"s|/var/log/celery/weblate-|/home/maposmatic/weblate/logs/celery-weblate-|g" \
    < $WEBLATE_PKG_DIR/examples/celery-weblate.conf \
    > /etc/default/celery-weblate

systemctl enable celery-weblate
systemctl start celery-weblate

sed -e"s|@INSTALLDIR@|$INSTALLDIR|g" \
    -e"s|@WEBLATE_PKG_DIR@|$WEBLATE_PKG_DIR|g" \
  < $FILEDIR/config-files/a2site-weblate.conf \
  > /etc/apache2/sites-available/weblate.conf

a2ensite weblate
systemctl restart apache2

deactivate
