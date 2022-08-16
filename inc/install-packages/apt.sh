#! /bin/bash

# we don't have "banner" installed yet at this point
echo "   ##    #####    #####          #####     ##     ####   #    #    ##     #### "
echo "  #  #   #    #     #            #    #   #  #   #    #  #   #    #  #   #    #"
echo " #    #  #    #     #            #    #  #    #  #       ####    #    #  #     "
echo " ######  #####      #            #####   ######  #       #  #    ######  #  ###"
echo " #    #  #          #            #       #    #  #    #  #   #   #    #  #    #"
echo " #    #  #          #            #       #    #   ####   #    #  #    #   #### "

# prevent configuration dialogs from popping up, we want fully automatic install
export DEBIAN_FRONTEND=noninteractive

# enable deb-src entries in apt sources list, needed for "apt build-dep"
sed -i -e 's/^# deb-src/deb-src/g' /etc/apt/sources.list

# bring apt package database up to date
#
# recent Ubuntu base boxes seem to do perform some apt action on startup, too,
# causing lock errors here, so we try until success
until apt-get update --quiet=2
do
  sleep 3
done

# install needed extra deb pacakges
apt-get install --quiet=2 --assume-yes \
    apache2 \
    apt-src \
    asciidoctor \
    cabextract \
    cmake \
    coderay \
    curl \
    emacs \
    expat \
    fonts-arkpandora \
    fonts-dejavu \
    fonts-dejavu-core \
    fonts-dejavu-extra \
    fonts-droid-fallback \
    fonts-khmeros \
    fonts-sil-padauk \
    fonts-sipa-arundina \
    fonts-taml-tscu \
    g++ \
    ghostscript \
    gir1.2-pango-1.0 \
    gir1.2-rsvg-2.0 \
    gobject-introspection \
    ccache \
    gdal-bin \
    gettext \
    git \
    imagemagick \
    libacl1-dev \
    libapache2-mod-fcgid \
    libapache2-mod-php \
    libapache2-mod-wsgi-py3 \
    libattr1-dev \
    libboost-python-dev \
    libbz2-dev \
    libcairo2-dev \
    libcgi-fast-perl \
    libexpat1-dev \
    libgdal-dev \
    libgirepository1.0-dev \
    libkakasi2-dev \
    liblua5.3-dev \
    libmapnik3.0 \
    libmapnik-dev \
    libosmium2-dev \
    libpython3-dev \
    libutf8proc-dev \
    libxml2-utils \
    libxslt1-dev \
    libyaml-dev \
    mapnik-utils \
    mc \
    mmv \
    munin \
    munin-node \
    munin-plugins-extra \
    osmctools \
    osmium-tool \
    pandoc \
    php-cli \
    php-http-request2 \
    php7.4-xml \
    pngquant \
    poedit \
    postgis \
    postgresql \
    postgresql-contrib \
    postgresql-server-dev-all \
    pv \
    python3-appdirs \
    python3-distlib \
    python3-django \
    python3-filelock \
    python3-future \
    python3-feedparser \
    python3-fiona \
    python3-gdal \
    python3-gdbm \
    python3-gi-cairo \
    python3-lxml \
    python3-mako \
    python3-mapnik \
    python3-markdown \
    python3-pip \
    python3-pil \
    python3-psycopg2 \
    python3-shapely \
    python3-slugify \
    python3-urllib3 \
    python3-virtualenv \
    redis \
    subversion \
    sysvbanner \
    texlive-extra-utils \
    texlive-latex-base \
    texlive-latex-recommended \
    time \
    transifex-client \
    tree \
    ttf-unifont \
    unifont \
    unifont-bin \
    unzip \
    virtualenv \
    wkhtmltopdf \
    > /dev/null || exit 3
