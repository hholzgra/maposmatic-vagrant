#----------------------------------------------------
#
# MapOSMatic web frontend installation & configuration
#
#----------------------------------------------------

# get maposmatic web frontend
cd $INSTALLDIR
git clone --quiet https://github.com/hholzgra/maposmatic.git
cd maposmatic
git checkout --quiet django-3.2

git remote add pushme git@github.com:hholzgra/maposmatic.git



# install dependencies
(cd www/static; HOME=/root npm install)

# create needed directories and tweak permissions
mkdir -p logs rendering/results media/upload

# copy config files
sed_opts="-e s|@INSTALLDIR@|$INSTALLDIR|g -e s|@INCDIR@|$INCDIR|g -e s|@LOGDIR@|$LOGDIR|g -e s|@DATADIR@|$DATADIR|g"
sed $sed_opts < $FILEDIR/config-files/config.py > scripts/config.py
sed $sed_opts < $FILEDIR/config-files/settings_local.py > www/settings_local.py
sed $sed_opts < $FILEDIR/config-files/maposmatic.wsgi > www/maposmatic.wsgi

# copy static files from django applications
python3 manage.py collectstatic --no-input

# the Ghostery browser plugin only allows specific javascript files
# to set cookie aceptance cookies, so we need to store the CookieLaw
# script file under a known whitelisted name
#
# see also https://github.com/hholzgra/maposmatic-vagrant/issues/64
cp cookielaw/js/cookielaw.js cookielaw/js/eu_cookie_compliance.min.js

# create import bounds information
cp $INSTALLDIR/bounds/bbox.py www/settings_bounds.py
echo "MAX_BOUNDING_OUTER='''" >> www/settings_bounds.py
cat $INSTALLDIR/bounds/outer.json >> www/settings_bounds.py
echo "'''" >> www/settings_bounds.py

# init MaposMatics housekeeping database
banner "Dj. Migration"
python3 manage.py makemigrations maposmatic
python3 manage.py migrate

# set up admin user
banner "Dj. Admin"
python3 manage.py shell -c "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'secret')"

# set up translations
banner "Dj. Translate"
python3 manage.py compilemessages

(cd documentation; make html 2>/dev/null; make install)

# fix directory ownerships
chown -R vagrant .
if test -f www/datastore.sqlite3
then
  chgrp www-data www www/datastore.sqlite3
  chmod   g+w    www www/datastore.sqlite3
fi
chgrp -R www-data media/upload logs
chmod -R g+w media/upload logs
chgrp maposmatic rendering/results
chmod a+w rendering/results

# set up render daemon
let MemHalf=$Mem_DB/2
sed_opts="$sed_opts -e s|@memlimit@|$MemHalf|g"
sed $sed_opts < $FILEDIR/systemd/maposmatic-render.service > /etc/systemd/system/maposmatic-render.service
sed $sed_opts < $FILEDIR/systemd/maposmatic-render@.service > /etc/systemd/system/maposmatic-render@.service
chmod 644 /etc/systemd/system/maposmatic*
systemctl daemon-reload

for queue in default api multipage
do
  systemctl enable maposmatic-render@$queue
  systemctl start maposmatic-render@$queue
done

# set up web server
service apache2 stop
sed $sed_opts < $FILEDIR/config-files/000-default.conf > /etc/apache2/sites-available/000-default.conf
service apache2 start
    
