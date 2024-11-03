#! /bin/bash

mkdir $INSTALLDIR/umap
cd $INSTALLDIR/umap
mkdir www
mkdir -p var/data

python -m venv venv
source venv/bin/activate

pip3 install umap-project

cp $FILEDIR/config-files/umap-settings.py local-settings.py

export UMAP_SETTINGS=`pwd`/local_settings.py

umap migrate

umap collectstatic

umap createsuperuser

umap runserver 0.0.0.0:8090 &

