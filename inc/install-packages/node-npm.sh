#! /bin/bash

# install extra npm packages
banner "npm packages"

### not needed for now as Lunar npm package is current enough
# ( curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash - ) > /dev/null
# sudo apt-get install --quiet=2 --assume-yes nodejs

npm config set loglevel warn

