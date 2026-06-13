#! /bin/bash

# install extra npm packages
banner "npm packages"

echo "... setting up"
( curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash - ) > /dev/null

echo "... installing nodejs package"
sudo apt-get install --quiet=2 --assume-yes nodejs

npm config set loglevel warn

echo "... installing carto"
npm install -g carto > /dev/null || exit 3

