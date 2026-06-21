#! /bin/bash -e

pushd . > /dev/null

DOWNLOAD_DIR=${CACHEDIR:-/vagrant/cache}/fonts
mkdir -p "$DOWNLOAD_DIR"

FONTDIR=/usr/local/share/fonts/truetype/noto
mkdir -p "$FONTDIR"

cd "$DOWNLOAD_DIR"
# wget --timestamping https://noto-website-2.storage.googleapis.com/pkgs/Noto-unhinted.zip
if ! test -d noto-fonts
then
  git clone https://github.com/notofonts/notofonts.github.io.git noto-fonts
else
  cd noto-fonts
  git pull
fi

cp fonts/*/unhinted/ttf/*.ttf "$FONTDIR"

unzip -qf "$DOWNLOAD_DIR"/Noto-unhinted.zip

popd > /dev/null
