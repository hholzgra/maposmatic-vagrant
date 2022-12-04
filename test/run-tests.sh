#! /bin/bash

### incude local override settings

if test -f ./run-tests-local-config
then
	. ./run-tests-local-config
fi

### default settings

# do not change these here, use the
# run-tests-local-config
# file to set different defaults instead

PROJECT=${PROJECT:-"/home/maposmatic"}
CONFIG=${CONFIG:-"$PROJECT/.ocitysmap.conf"}

LAYOUT=${LAYOUT:-"plain"}
ORIENTATION=${ORIENTATION:-"landscape"}

BBOX=${BBOX:-"52.0100,8.5122 52.0300,8.5432"} # Bielefeld

LANG=${LANG:-"de_DE.utf8"}

PAPER=${PAPER:-"Din A4"}
THUMB_WIDTH=${THUMB_WIDTH:-400}

INDEX=${INDEX:-"Street"}

BASE_FOR_OVERLAY=${BASE_FOR_OVERLAY:-"Empty"}
PREVIEW_DIR=${PREVIEW_DIR:-"/home/maposmatic/maposmatic/www/static/img/"}

PYTHON="python3"


### create reduced size preview images in several resolutions
make_previews () {
    png=$1
    name=$2
    script=$3

    jpg=$(echo $png | sed -e's/-png.png/-jpg.jpg/g')
    thumb="thumbmails/"$(basename $png .png).jpg
    echo "convert $png $jpg" >> $script
    echo "convert -thumbnail $THUMB_WIDTH $png $thumb" >> $script

    if test -n "$PREVIEW_DIR"
    then
	echo "convert -resize  500x355 $png $PREVIEW_DIR/$name.png"      >> $script
	echo "convert -resize  750x533 $png $PREVIEW_DIR/$name-1.5x.png" >> $script
	echo "convert -resize 1000x710 $png $PREVIEW_DIR/$name-2x.png"   >> $script
    fi


}

make_previews_multi() {
    # TODO use "pdfinfo ... | grep ^Pages:" to find actual PDF page count,
    #      and guess good detail and index page numbers based on that
    #      instead of hard coded pages 5 and 10

    script=$1
    width=$2
    height=$3
    factor=$4

    single_size="${width}x${height}"
    full_size=$(bc <<< "$width*2.5/1")"x"$(bc <<< "$height*1.27/1")
    dw=$(bc <<< "$width/2")
    dh=$(bc <<< "$height/14")
    offset1="+"$(bc <<< "$dw*3")"+"$(bc <<< "$dh*3")
    offset2="+"$(bc <<< "$dw*2")"+"$(bc <<< "$dh*2")
    offset3="+"$dw"+"$dh

    echo "convert layout-multi_page-0.png  -resize $single_size layout-multi_page-title$factor.png" >> $script
    echo "convert layout-multi_page-2.png  -resize $single_size layout-multi_page-overview$factor.png" >> $script
    echo "convert layout-multi_page-5.png  -resize $single_size layout-multi_page-detail$factor.png" >> $script
    echo "convert layout-multi_page-10.png -resize $single_size layout-multi_page-index$factor.png" >> $script

    echo "convert -size $full_size canvas:none \
            layout-multi_page-index$factor.png     -geometry  $offset1 -composite \
            layout-multi_page-detail$factor.png    -geometry  $offset2 -composite \
            layout-multi_page-overview$factor.png  -geometry  $offset3 -composite \
            layout-multi_page-title$factor.png     -geometry  +0+0     -composite \
            layout-multi_page-all$factor.png" >> $script

    echo "cp layout-multi_page-all$factor.png $PREVIEW_DIR/layout/multi_page$factor.png" >> $script
}

### make layout preview
make_layout_preview() {
    layout=$1
    title=$2
    format=$3

    base="layout-$layout"

    cmd="ocitysmap"
    cmd+=" --config=$CONFIG"
    cmd+=" --bounding-box=$BBOX"
    cmd+=" --title='$title'"
    cmd+=" --prefix='layout-$layout'"
    cmd+=" --layout=$layout"
    cmd+=" --style=CartoOSM"
    cmd+=" --language=$LANG"
    cmd+=" --paper-format='$PAPER'"
    if test "$format" = "pdf"
    then
	cmd+=" --orientation=portrait"
    else
	cmd+=" --orientation=landscape"
    fi
    echo $cmd > $base.sh


    # create previews for single page formats only
    if test "$format" = "png"
    then
       make_previews "$base.png" "layout/$layout" "$base.sh"
    else
	echo "convert -density 300 layout-multi_page.pdf layout-multi_page.png" >> $base.sh

	make_previews_multi $base.sh 200 280 ""
	make_previews_multi $base.sh 320 420 "-1.5x"
	make_previews_multi $base.sh 400 560 "-2x"
    fi

    chmod a+x $base.sh
    echo "/usr/bin/time -q -f '%E' -o $base.time ./$base.sh > $base.log 2> $base.err; echo -n '$layout preview done in '; cat $base.time" >> test-run.sh
}

### create actual render command line
make_cmd() {
    base="$1"
    style="$2"
    mode="$3"
    format="$4"

    cmd="ocitysmap"
    cmd+=" --config=$CONFIG"
    cmd+=" --bounding-box=$BBOX"
    cmd+=" --title='Test $style ($format)'"
    cmd+=" --prefix=$base"
    cmd+=" --index=$INDEX"
    cmd+=" --language=$LANG"
    cmd+=" --orientation=$ORIENTATION"
    cmd+=" --paper-format='$PAPER'"
    if [ "$format" == "multi" ]
    then
	cmd+=" --format=pdf"
	cmd+=" --layout=multi_page"
    else
        cmd+=" --format=$format"
	cmd+=" --layout=$LAYOUT"
    fi
    if [ "$mode" == "overlay" ]
    then
	cmd+=" --style='$BASE_FOR_OVERLAY' --overlay=$style"
    else
	cmd+=" --style=$style"
    fi

    echo $cmd
}

# render map in various file formats
make_map() {
    style="$1"
    mode="$2" # base or overlay

    for format in png pdf svgz multi
    do
        base=test-$mode-$style-$format
	make_cmd $base $style $mode $format >> $base.sh

	if test "$format" == "png"
	then
	    make_previews test-base-$style-png.png "style/$style" "$base.sh"
	fi

	chmod a+x $base.sh
	echo "/usr/bin/time -q -f "%E" -o $base.time ./$base.sh > $base.log 2> $base.err; echo -n '$style $mode $format done in '; cat $base.time " >> test-run.sh
    done
}

rm -f test-run.sh

if test $# -gt 0
then
  # get styles to re-render from command line
  STYLES=""
  OVERLAYS=""
  while [ $1 ] ; do
    if ( echo $1 | egrep -q '\s*#' ); then
      echo "Ignoring $1"
      shift
      continue
    elif ( echo $1 | grep -qi Overlay); then
      OVERLAYS="$OVERLAYS $1"
    else
      STYLES="$STYLES $1"
    fi
    shift
  done
else
  # with no explicit styles requested we remove and re-render everything
  STYLES=$(grep ^name= $CONFIG | grep -v '#' | grep -vi 'Overlay' | sed -e 's/name=//g' | sort)
  OVERLAYS=$(grep ^name= $CONFIG | grep -v '#' | grep -i 'Overlay' | sed -e 's/name=//g'  | sort)
  rm -rf test-* thumbnails/test-* layout-*
fi

## render

# TODO move preview img generation to own script,
#      enroll different sizes in loop
#      import BBOX and PAPER from common include script

if ! test -f layout-plain.png
then
   make_layout_preview "plain" "Plain" "png"
fi

if ! test -f layout-side-index.png
then
   make_layout_preview "single_page_index_side" "Side index" "png"
fi

if ! test -f layout-bottom-index.png
then
   make_layout_preview "single_page_index_bottom" "Bottom index" "png"
fi

if ! test -f layout-multi_page.png
then
   make_layout_preview "multi_page" "Multi page" "pdf"
fi

for style in $STYLES
do
  rm -f test-base-$style-*

  make_map $style "base"

done

for style in $OVERLAYS
do
  rm -f test-overlay-$style-*

  make_map $style "overlay"
done

chmod a+x test-run.sh
parallel --eta < test-run.sh

echo "all rendering done, updating index pages"
php index.php > index.html
( cd thumbnails && php index.php > index.html )

