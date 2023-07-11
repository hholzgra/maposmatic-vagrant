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
# and add "contrib" repos for stuff like ttf-mscorefonts-installer
sed -i -e 's/^# deb-src/deb-src/g' -e's/main/main contrib/g' /etc/apt/sources.list

# bring apt package database up to date
#
# recent Ubuntu base boxes seem to do perform some apt action on startup, too,
# causing lock errors here, so we try until success
until apt-get update --quiet=2
do
  sleep 3
done

# install needed extra deb pacakges
apt-get --quiet install --assume-yes \
    apache2 \
    apt-src \
    asciidoctor \
    bc \
    cabextract \
    cmake \
    coderay \
    curl \
    emacs \
    expat \
    figlet \
    fonts-arkpandora \
    fonts-dejavu \
    fonts-dejavu-core \
    fonts-dejavu-extra \
    fonts-droid-fallback \
    fonts-khmeros \
    fonts-sil-padauk \
    fonts-sipa-arundina \
    fonts-taml-tscu \
    fonts-unifont \
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
    libapache2-mod-tile \
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
    libmapnik3.1 \
    libmapnik-dev \
    libosmium2-dev \
    libpython3-dev \
    libutf8proc-dev \
    libxml2-utils \
    libxslt1-dev \
    libyaml-dev \
    lua5.3 \
    mapnik-utils \
    mc \
    mmv \
    munin \
    munin-node \
    munin-plugins-extra \
    nlohmann-json3-dev \
    osmctools \
    osmium-tool \
    pandoc \
    parallel \
    php-cli \
    php-xml \
    pigz \
    pngquant \
    poedit \
    poppler-utils \
    postgis \
    postgresql \
    postgresql-contrib \
    postgresql-server-dev-all \
    pv \
    python-is-python3 \
    python3-appdirs \
    python3-babel \
    python3-colour \
    python3-cssselect \
    python3-distlib \
    python3-django \
    python3-django-maintenance-mode \
    python3-filelock \
    python3-future \
    python3-feedparser \
    python3-fiona \
    python3-gdal \
    python3-gdbm \
    python3-geoalchemy2 \
    python3-geopy \
    python3-gi-cairo \
    python3-gpxpy \
    python3-jinja2 \
    python3-lxml \
    python3-mako \
    python3-mapnik \
    python3-markdown \
    python3-natsort \
    python3-pip \
    python3-pil \
    python3-pluginbase \
    python3-psutil \
    python3-psycopg2 \
    python3-pyproj \
    python3-qrcode \
    python3-shapely \
    python3-slugify \
    python3-tinycss \
    python3-urllib3 \
    python3-venv \
    python3-virtualenv \
    redis \
    renderd \
    subversion \
    sysvbanner \
    texlive-extra-utils \
    texlive-latex-base \
    texlive-latex-recommended \
    time \
    tree \
    unifont \
    unifont-bin \
    unzip \
    virtualenv \
    wkhtmltopdf \
    > /dev/null || exit 3

