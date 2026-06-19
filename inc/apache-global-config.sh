#! /bin/bash -e

sed -i -e 's/export LANG=C/#export LANG=C/' -e's/#. \/etc\/default\/locale/. \/etc\/default\/locale/' /etc/apache2/envvars
