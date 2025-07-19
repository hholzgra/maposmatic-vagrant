#! /bin/bash

# download / install extra fonts
banner "extra fonts"

(
    cd $INCDIR/fonts;
    for script in *.sh
    do
	basename $script ".sh"
	( . $script );
    done
)

fc-cache -f # not needed for Mapnik, but good practice nonetheless

