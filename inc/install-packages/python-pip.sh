#! /bin/bash

banner "python packages"

python3 -m venv --system-site-packages $INSTALLDIR/virtual-env
. $INSTALLDIR/virtual-env/bin/activate

pip3 install \
     django-cookie-law \
     django-multiupload \
     django-maintenance-mode \
     fastnumbers \
     jsonpath_ng \
     osmium \
     pillow \
     psycopg[binary,pool] \
     slugify \
     "sqlalchemy>=1.4,<2.0" \
     "sqlalchemy-utils" \
     || exit 3

# we can't uninstall the Ubuntu python3-pycairo package
# due to too many dependencies, but we need to make sure
# that we actually use the current pip pacakge to get
# support for PDF set_page_label() which the version
# of pycairo that comes with Ubuntu does not have yet
pip3 install --ignore-installed pycairo > /dev/null || exit 3


