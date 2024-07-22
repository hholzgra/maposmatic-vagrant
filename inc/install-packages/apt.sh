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
    build-essential \
    cabextract \
    cmake \
    coderay \
    command-not-found \
    curl \
    emacs \
    expat \
    figlet \
    fonts-* \
    g++ \
    ghostscript \
    gir1.2-pango-1.0 \
    gir1.2-rsvg-2.0 \
    gobject-introspection \
    ccache \
    gdal-bin \
    gettext \
    gir1.2-pango-1.0 \
    git \
    git-svn \
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
    libffi-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libgdal-dev \
    libgirepository1.0-dev \
    libkakasi2-dev \
    libldap-common \
    libldap2-dev \
    liblua5.3-dev \
    libmapnik3.1 \
    libmapnik-dev \
    libosmium2-dev \
    libpq-dev \
    libpython3-dev \
    libsasl2-dev \
    libssl-dev \
    libutf8proc-dev \
    libxml2-dev \
    libxml2-utils \
    libxmlsec1-dev \
    libxslt1-dev \
    libyaml-dev \
    libz-dev \
    lua5.3 \
    mapnik-utils \
    mc \
    mmv \
    munin \
    munin-node \
    munin-plugins-extra \
    net-tools \
    nlohmann-json3-dev \
    ntp \
    ntpsec-ntpdate \
    osm2pgsql \
    osmctools \
    osmium-tool \
    pandoc \
    parallel \
    pgtop \
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
    python3-dev \
    python3-future \
    python3-gdbm \
    python3-gi-cairo \
    python3-mapnik \
    python3-pip \
    python3-pil \
    python3-virtualenv \
    redis \
    renderd \
    strace \
    subversion \
    sysvbanner \
    tcpdump \
    texlive-extra-utils \
    texlive-latex-base \
    texlive-latex-recommended \
    time \
    tree \
    fonts-unifont \
    unifont \
    unifont-bin \
    unzip \
    vim \
    virtualenv \
    w3m \
    wkhtmltopdf \
    > /dev/null || exit 3

