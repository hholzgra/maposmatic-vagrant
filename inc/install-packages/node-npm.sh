#! /bin/bash -e

# install extra npm packages
banner "npm packages"

# install nodejs from upstream if not already available yet
if ! which npm >/dev/null
then
    echo "... setting up"
    ( curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash - ) > /dev/null
fi

npm config set loglevel warn

echo "... installing carto"
npm install -g carto > /dev/null || exit 3

