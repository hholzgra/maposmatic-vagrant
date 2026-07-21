#! /bin/bash -e

# this may cause crashes on fetching OSM diffs with osmium, so lets remove it for now
# apt-get remove -y python3-apport > /dev/null

banner "python packages"

virtualenv --system-site-packages "$INSTALLDIR"
. "$INSTALLDIR"/bin/activate

pip3 install --ignore-installed \
     appdirs \
     attrs \
     babel \
     certifi \
     cachetools \
     charset_normalizer \
     click \
     click-plugins \
     cligj \
     colour \
     cssselect \
     distlib \
     "Django<6" \
     django-cookie-law \
     django-ipware \
     django-maintenance-mode \
     django-multiupload \
     django-settings-export \
     fastnumbers \
     feedparser \
     filelock \
     fiona \
     "gdal==$(gdal-config --version)" \
     GitPython \
     geoalchemy2 \
     geopy \
     gpxpy \
     idna \
     jinja2 \
     jsonpath_ng \
     lxml \
     mako \
     natsort \
     numpy \
     osmium \
     pillow \
     pluginbase \
     psutil \
     psycopg2 \
     pyproj \
     python-slugify \
     requests \
     qrcode \
     shapely \
     six \
     "sqlalchemy>=1.4,<2.0" \
     "sqlalchemy-utils" \
     tinycss \
     unicode \
     urllib3 \
     utm \
     validators \
     >/dev/null || exit 3

# pip repository version of django-multiupload not compatible with Django 2.1+ yet
# pip3 install -e git+https://github.com/Chive/django-multiupload.git#egg=django-multiupload > /dev/null || exit 3
# pip3 install -e git+https://github.com/Chive/django-multiupload.git#egg=multiupload > /dev/null || exit 3

# we can't uninstall the Ubuntu python3-pycairo package
# due to too many dependencies, but we need to make sure
# that we actually use the current pip pacakge to get
# support for PDF set_page_label() which the version
# of pycairo that comes with Ubuntu does not have yet
pip3 install --ignore-installed --break-system-packages pycairo > /dev/null || exit 3


