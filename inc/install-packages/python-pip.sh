#! /bin/bash

# this may cause crashes on fetching OSM diffs with osmium, so lets remove it for now
# apt-get remove -y python3-apport > /dev/null

banner "python packages"
pip3 install \
     django-cookie-law \
     django-multiupload \
     fastnumbers \
     jsonpath_ng \
     osmium \
     pillow \
     "sqlalchemy>=1.4,<2.0" \
     "sqlalchemy-utils" \
     >/dev/null || exit 3

# pip repository version of django-multiupload not compatible with Django 2.1+ yet
# pip3 install -e git+https://github.com/Chive/django-multiupload.git#egg=django-multiupload > /dev/null || exit 3
# pip3 install -e git+https://github.com/Chive/django-multiupload.git#egg=multiupload > /dev/null || exit 3

# we can't uninstall the Ubuntu python3-pycairo package
# due to too many dependencies, but we need to make sure
# that we actually use the current pip pacakge to get
# support for PDF set_page_label() which the version
# of pycairo that comes with Ubuntu does not have yet
pip3 install --ignore-installed pycairo > /dev/null || exit 3


