#! /bin/bash

cd $INSTALLDIR

# read SRTM 90m zone name -> area mapping table
echo "Importing SRTM zone database"
sudo -u maposmatic psql gis < $FILEDIR/database/db_dumps/srtm_zones.sql > /dev/null

mkdir -p elevation-data
cd elevation-data

echo "Downloading SRTM arcive files"

mkdir -p srtm-data
cd srtm-data

mkdir -p $CACHEDIR/srtm-data $CACHEDIR/srtm $CACHEDIR/dem

# extract bounding box data in bash array format
bbox=$(cat $INSTALLDIR/bounds/bbox.bash)

# create actaul bounding box bash array
eval b=$bbox

# create bounding box polygon WKT string
polygon="POLYGON((${b[1]} ${b[0]}, ${b[1]} ${b[2]}, ${b[3]} ${b[2]}, ${b[3]} ${b[0]}, ${b[1]} ${b[0]}))"

# now download all zones the import bounding box overlaps with
for zone in $(psql gis --tuples-only --command="select zone from srtm_zones where ST_INTERSECTS(way, ST_GeomFromText('$polygon', 4326))")
do
    CACHEFILE=$CACHEDIR/srtm-data/$zone.zip
    SRTM_URL=http://viewfinderpanoramas.org/dem3/$zone.zip
    if ! test -f $CACHEFILE
    then
        echo "  downloading zone $zone"
        wget -q -O $CACHEFILE $SRTM_URL
    fi
    unzip -q $CACHEFILE
done

cd ..




echo "SRTM hillshading for PisteMap"

mkdir -p srtm
cd srtm

rm -f jobs-adapted.txt jobs-warped.txt jobs-hillshade.txt

for file in $(find $INSTALLDIR/elevation-data/srtm-data/ -name "*.hgt" | sort)
do
    base=$(basename $file .hgt)
    cache_base=$CACHEDIR/srtm/${base}

    echo -n "  processing $base "

    echo -n "adapt "
    if test -f ${cache_base}_adapted.tif
    then
        cp ${cache_base}_adapted.tif .
        echo -n "cached, "
    else
        echo "gdal_translate -q -of GTiff -co 'TILED=YES' -a_srs '+proj=latlong' $file ${base}_adapted.tif" >> jobs-adapted.txt
        echo -n "planned, "
    fi

    echo -n "warp "
    if test -f ${cache_base}_warped.tif
    then
        cp ${cache_base}_warped.tif .
        echo -n "cached, "
    else
        echo "gdalwarp -q -multi -of GTiff -co 'TILED=YES' -srcnodata 32767 -t_srs '+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m' -rcs -order 3 -tr 30 30 -multi ${base}_adapted.tif ${base}_warped.tif" >> jobs-warped.txt
        echo -n "planned, "
    fi

    echo -n "hillshade "
    if test -f ${cache_base}_hillshade.tif
    then
        cp ${cache_base}_hillshade.tif .
        echo "cached"
    else
        echo "gdaldem hillshade -q ${base}_warped.tif ${base}_hillshade.tif" >> jobs-hillshade.txt
        echo "planned"
    fi
done

for job in adapted warped hillshade
do
    jobfile=jobs-$job.txt
    test -f $jobfile && parallel < $jobfile
done

rm -f jobs-*.txt

cp --update *.tif $CACHEDIR/srtm/

cd ..




echo "DEM data for OpenTopoMap"
# see also: https://github.com/der-stefan/OpenTopoMap/blob/master/mapnik/HOWTO_DEM.md


mkdir -p dem
cd dem

# file taken from OpenTopoMap repository, which may not be installed at this point yet
cp $FILEDIR/relief_color_text_file.txt .

# fill empty spaces
for file in $(find $INSTALLDIR/elevation-data/srtm-data -name "*.hgt" | sort)
do
  base=$(basename $file)
  echo -n "  processing $base "
  cache_base=$CACHEDIR/dem/${base}
  if test -f ${cache_base}.tif
  then
      cp ${cache_base}.tif .
      echo "cached"
  else
      gdal_fillnodata.py -q $file ${base}.tif
      cp ${base}.tif ${cache_base}.tif
      echo "done"
  fi
done

# merge all elevation data into one single large tiled file
echo "merging data into single file"
gdal_merge.py -n 32767 -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -o raw.tif *.hgt.tif -q

ln -s raw.tif dem-srtm.tiff
ln -s raw.tif dem_srtm.tiff

rm -f jobs.txt

# convert to google mercator projection
interpolation=cubicspline # for first level
for r in 90 500 1000 5000
do
  echo "interpolation $r"
  echo "gdalwarp -co BIGTIFF=YES -co TILED=YES -co COMPRESS=LZW -co PREDICTOR=2 -t_srs '+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m' -r $interpolation -tr $r $r raw.tif warp-$r.tif -q" >> jobs.txt
  interpolation=bilinear # for all later levels
done

parallel < jobs.txt

rm jobs.txt

# create colored reliefs for low zoom levels
echo "low color reliefs"
echo "gdaldem color-relief -co COMPRESS=LZW -co PREDICTOR=2 -alpha warp-5000.tif relief_color_text_file.txt relief-5000.tif -q" >> jobs.txt
echo "gdaldem color-relief -co COMPRESS=LZW -co PREDICTOR=2 -alpha warp-500.tif  relief_color_text_file.txt relief-500.tif -q" >> jobs.txt

# create hillshading
echo "hillshading"
echo "gdaldem hillshade -z 7 -compute_edges -co COMPRESS=JPEG warp-5000.tif hillshade-5000.tif -q" >> jobs.txt
echo "gdaldem hillshade -z 7 -compute_edges -co BIGTIFF=YES -co TILED=YES -co COMPRESS=JPEG warp-1000.tif hillshade-1000.tif -q" >> jobs.txt
echo "gdaldem hillshade -z 4 -compute_edges -co BIGTIFF=YES -co TILED=YES -co COMPRESS=JPEG warp-500.tif hillshade-500.tif -q" >> jobs.txt
echo "gdaldem hillshade -z 7 -combined -compute_edges -co compress=lzw -co predictor=2 -co bigtiff=yes warp-90.tif hillshade-90.tif -q" >> jobs.txt
# TODO: not used? gdal_translate -co compress=JPEG -co bigtiff=yes -co tiled=yes hillshade-90.tif hillshade-90-jpeg.tif -q

parallel < jobs.txt

rm jobs.txt

# set up countours database and table schema
echo "create contour db"
sudo -u maposmatic psql --quiet gis < $FILEDIR/database/db_dumps/contours_schema.sql

# create contours shapefile and imports its data into the database
echo "gdal_contour"
gdal_contour -i 10 -a ele warp-90.tif contour.shp -q
echo "shp2pgsql"
shp2pgsql -a -g way -s 3857 contour.shp contours | psql --quiet contours

cd ..

