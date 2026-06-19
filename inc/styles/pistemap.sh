#! /bin/bash -e

cd $STYLEDIR

git clone --quiet https://gitlab.com/hholzgra/pistemap.git

cd pistemap
git checkout --quiet maposmatic

# fetch additional files required by this style
ln -s $SHAPEFILE_DIR/world_boundaries .


cd pistemap_symbols
ln -s ../../MapQuest-Mapnik-Style/mapquest_symbols/small-city.svg .
ln -s ../../MapQuest-Mapnik-Style/mapquest_symbols/large-city.svg .
ln -s ../../MapQuest-Mapnik-Style/mapquest_symbols/national-capital.svg .
cd ..

ln -s $INSTALLDIR/elevation-data/srtm/ .

cat <<EOF > pistemap_inc/layer-hillshade.xml.inc
<Style name="raster">
        <Rule>
                &maxscale_zoom6;
                <RasterSymbolizer scaling="bilinear" mode="multiple">
                   <RasterColorizer default-mode="linear" default-color="#008000" epsilon="2">
                      <stop color="#006080" value="0" mode="linear" />
                      <stop color="#ffffff" value="256" mode="linear" />
                   </RasterColorizer>
                </RasterSymbolizer>
        </Rule>
</Style>
EOF

for hillshade in $INSTALLDIR/elevation-data/srtm/*hillshade.tif
do
    cat << EOF >> pistemap_inc/layer-hillshade.xml.inc
<Layer name="dem-${base}" status="on">
        <StyleName>raster</StyleName>
        <Datasource>
                <Parameter name="type">gdal</Parameter>
                <Parameter name="file">$hillshade</Parameter>
                <Parameter name="format">tiff</Parameter>
                <Parameter name="band">1</Parameter>
        </Datasource>
</Layer>

EOF
done


