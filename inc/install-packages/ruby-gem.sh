#! /bin/bash

banner "ruby packages"
gem install --pre asciidoctor-pdf > /dev/null || exit 3 
NOKOGIRI_USE_SYSTEM_LIBRARIES=1 gem install asciidoctor-epub3 > /dev/null || exit 3

