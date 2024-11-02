#! /bin/bash
# 
# Central download script for all shapefiles needed by 
# the supported Mapnik Stylesheets

if tty
then
    SAME_LINE="-n"
else
    SAME_LINE=""
fi

echo
echo "Downloading and preprocessing shapefiles"
echo

#
# preparations
#

# download/cache directory for downloaded shapefile archives
DOWNLOAD_DIR=${CACHEDIR:-/vagrant/cache}/shapefiles
mkdir -p $DOWNLOAD_DIR

# actual shapefile directory tree
SHAPEFILE_DIR=${SHAPEFILE_DIR:-/home/maposmatic/shapefiles}
mkdir -p $SHAPEFILE_DIR

#
# base URLs for the different spapefile servers
# and actual shapefiles to be downloaded from them
#

URLS=""

# osmdata - maintained by Jochen Topf and Christof Hormann,
#   hardware sponsored by FOSSGIS e.V., Germany
OSMDATA=https://osmdata.openstreetmap.de/download

URLS+="$OSMDATA/land-polygons-split-3857.zip "
URLS+="$OSMDATA/simplified-land-polygons-complete-3857.zip "
URLS+="$OSMDATA/simplified-water-polygons-split-3857.zip "
URLS+="$OSMDATA/water-polygons-split-3857.zip "
URLS+="$OSMDATA/coastlines-split-3857.zip "
URLS+="$OSMDATA/antarctica-icesheet-outlines-3857.zip "
URLS+="$OSMDATA/antarctica-icesheet-polygons-3857.zip "

# legacy files originally provided by osmdata, but discontinued
OSMDATA_OLD=http://osm-baustelle.de/downloads

URLS+="$OSMDATA_OLD/lakes-polygons-reduced-3857.zip "
URLS+="$OSMDATA_OLD/ocean-polygons-reduced-3857.zip "
URLS+="$OSMDATA_OLD/river-polygons-reduced-3857.zip "
URLS+="$OSMDATA_OLD/simplified-water-polygons-complete-3857.zip "
URLS+="$OSMDATA_OLD/water-polygons-generalized-3857.zip "

# Natural Earth shapefiles
NATURAL_EARTH=https://naturalearth.s3.amazonaws.com

URLS+="$NATURAL_EARTH/10m_cultural/ne_10m_admin_0_boundary_lines_land.zip "
URLS+="$NATURAL_EARTH/10m_cultural/ne_10m_admin_0_boundary_lines_map_units.zip "
URLS+="$NATURAL_EARTH/10m_cultural/ne_10m_admin_0_countries_lakes.zip "
URLS+="$NATURAL_EARTH/10m_cultural/ne_10m_admin_1_states_provinces_lines.zip "
URLS+="$NATURAL_EARTH/10m_cultural/ne_10m_airports.zip "
URLS+="$NATURAL_EARTH/10m_cultural/ne_10m_populated_places.zip "
URLS+="$NATURAL_EARTH/10m_cultural/ne_10m_populated_places_simple.zip "
URLS+="$NATURAL_EARTH/10m_cultural/ne_10m_roads.zip "

URLS+="$NATURAL_EARTH/10m_physical/ne_10m_coastline.zip "
URLS+="$NATURAL_EARTH/10m_physical/ne_10m_geography_marine_polys.zip "
URLS+="$NATURAL_EARTH/10m_physical/ne_10m_lakes.zip "
URLS+="$NATURAL_EARTH/10m_physical/ne_10m_land.zip "
URLS+="$NATURAL_EARTH/10m_physical/ne_10m_ocean.zip "

URLS+="$NATURAL_EARTH/50m_cultural/ne_50m_admin_0_boundary_lines_land.zip "
URLS+="$NATURAL_EARTH/50m_cultural/ne_50m_admin_0_countries_lakes.zip "
URLS+="$NATURAL_EARTH/50m_cultural/ne_50m_admin_1_states_provinces_lines.zip "
URLS+="$NATURAL_EARTH/50m_physical/ne_50m_geography_marine_polys.zip "
URLS+="$NATURAL_EARTH/50m_physical/ne_50m_lakes.zip "
URLS+="$NATURAL_EARTH/50m_physical/ne_50m_land.zip "

URLS+="$NATURAL_EARTH/110m_cultural/ne_110m_admin_0_boundary_lines_land.zip "
URLS+="$NATURAL_EARTH/110m_physical/ne_110m_geography_marine_polys.zip "

# Shapefile(s) specific to the Veloroad style
VELOROAD=http://zverik.openstreetmap.ru

URLS+="$VELOROAD/gmted25.tar.xz "

# some legacy shapefiles still needed by older unmaintained styles
OSM_HISTORICAL=http://planet.openstreetmap.org/historical-shapefiles

URLS+="$OSM_HISTORICAL/world_boundaries-spherical.tgz "
URLS+="$OSM_HISTORICAL/shoreline_300.tar.bz2 "
URLS+="$OSM_HISTORICAL/processed_p.tar.bz2 "

# legacy files no longer online elsewhere, so that I'm hosting my own copies
# TODO: these are not containing actual shapefiles, so should be downloaded
# separately?
OSM_BAUSTELLE=http://www.osm-baustelle.de/downloads

URLS+="$OSM_BAUSTELLE/mercator_tiffs.tar.bz2"


#
# download and process all shapefile archives
#
for url in $URLS
do
    cd $DOWNLOAD_DIR
    
    # some basic file name processing
    archive=$(basename $url)
    ext=${archive#*.}
    archbase=$(basename $archive .$ext)
    
    echo $SAME_LINE "downloading $archive"

    # remove extra backup if exists
    rm -f $archive.1

    # download the file only if newer than the localy cached copy
    if ! wget --quiet --timestamping --backups=1 --no-check-certificate --timeout=30 --tries=1 "$url"
    then
	echo " ... wget failed: $url"

	if ! test -f $archive
	then
	    # try go get from our own backup server
	    echo $SAME_LINE "trying backup archive "
            filename=$(basename "$url")
	    if ! wget --quiet --timeout=30 --tries=1 https://get-map.org/downloads/shapefile-backups/$filename
	    then
	        # could not find it in any of the known places
		# -> skip further processing, continue with next shapefile in list
		echo "skipping $filename"
                continue
            fi
	fi
    fi

    file_type=$(file -bi $archive | sed -e's/;.*$//g')
    case $file_type in
	application/gzip)
        ;;
	application/x-bzip2)
        ;;
	application/x-xz)
        ;;
	application/zip)
        ;;
	*)
	    # download is not a known archive type, so something seems
	    # to have gone wrong and we try to roll back to the previous
	    # downloaded version
	    rm $archive
	    if test -f $archive.1
	    then
		mv $archive.1 $archive
	    fi
	    echo " ... wrong file type $file_type"
	    continue
	;;
    esac
	
    # renew actual shapefile if a more recent version was downloaded (new backup exists)
    # or process shapefile archive (from download or cache) if actual shapefile not found
    if [ \( -f $DOWNLOAD_DIR/$archive.1 \) -o \( ! -d $SHAPEFILE_DIR/$archbase \) ]
    then
	echo $SAME_LINE " ... unpacking"

        # again: remove the backup file if it exists
        rm -f $archive.1

        # change workplace
        cd $SHAPEFILE_DIR

        # create temporary workdir, we'll rename it on success later
        rm -rf tmp
	mkdir tmp
        cd tmp

        # unpack downloaded archive
	if [ $ext = 'zip' ]
        then
            unzip -q $DOWNLOAD_DIR/$archive
        else
	    tar -xf $DOWNLOAD_DIR/$archive
        fi

	echo $SAME_LINE " ... indexing"
	for shppath in $(find . -name '*.shp')
	do
	    shpfile=$(basename $shppath)
	    shpdir=$(dirname $shppath)
	    (
	      cd $shpdir
	      shapeindex --shape_files $shpfile >/dev/null 2>/dev/null
	    )
	done

        # if there's only one object in the tmp dir now we have a 
	# 'nice' archive with everything in a subdirectory of its
	# own, and we just move that subdir
        # if there's more than one object then the archive didn't
	# have a top level subdir, everything was unpacked in tmp
	# right away, and we rename the tmpdir
        if [ $(ls | wc -l) -eq 1 ]
        then
	    base=$(ls)
	    rm -rf ../$archbase 
	    mv $base ../$archbase
	    cd ..
	    rm -rf tmp 
        else
            cd ..
	    rm -rf $archbase
	    mv tmp $archbase
        fi
	echo
    else
	echo " ... unchanged"
    fi
done

#
# some files require special post processing
#

echo; echo "Post-Processing"; echo

# TODO: I don't remember why, and for what style, this recoding was actually necessary for
cd $SHAPEFILE_DIR/ne_10m_populated_places
ogr2ogr --config SHAPE_ENCODING UTF8 ne_10m_populated_places_fixed.shp ne_10m_populated_places.shp

# some styles epect the mercator tiff files in the top level shapefile dir
cd $SHAPEFILE_DIR
for a in mercator_tiffs/*.tif
do 
    rm -f $(basename $a)
    ln -s $a .
done

# the gmted shapefile dir is referenced by a different name than the archives basename
ln -sf gmted25 gmted

#
# Some older styles expect all shapefiles in a single directory "world_boundaries"
# instead of having one subdir per shapefile archive. So we're going to populate 
# such a directory with symlinks to the actual file
#

# make sure that the new dir exists and is empty
rm -rf world_boundaries_new
mkdir world_boundaries_new

# link files from a known list of shapefile directories only
for shpdir in world_boundaries-spherical shoreline_300 ne_10m_populated_places ne_110m_admin_0_boundary_lines_land mercator_tiffs land-polygons-split-3857 simplified-land-polygons-complete-3857 processed_p
do
	# for each file in there
	for file in $shpdir/*
	do
		# create a symlink in the new world boundaries dir
		# unless the same file name already exists in there
		base=$(basename $file)
		path=$(realpath $file)
		ln -sf $path world_boundaries_new/$base
	done
done

# some files are referenced by an older name, so we create symlins for these, too
cd world_boundaries_new
for source in ne_110m_admin_0_boundary_lines_land.*
do
	dest=$(echo $source | sed -e's/ne_110/110/g')
	echo ln -sf $source $dest
	ln -sf $source $dest
done
cd ..

# now replace previous wourld_boundaries with the new version
rm -rf world_boundaries
mv world_boundaries_new world_boundaries

#
# done
#

echo "done"



