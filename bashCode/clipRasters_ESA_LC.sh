#!/bin/bash

SHPFILE='/home/eline91/shared/userdata3/vectorData/AreaClip.shp'

# set path for output files here
DIR_OUT='/home/eline91/shared/userdata3/rasterData/ESA_landcover_clipped'

for FILE in *.tif
do
 FILENEW=`echo $FILE | sed "s/.tif/_clipped.tif/"`
 OUTFILE="$DIR_OUT/$FILENEW"
 if [ -f "$OUTFILE" ]
 then
 	echo "$OUTFILE exists, continue processing next file."
 else
	echo "$OUTFILE does not exists. Processing file...."
	gdalwarp -co SPARSE_OK=TRUE -co INTERLEAVE=PIXEL -co COMPRESS=DEFLATE -co ZLEVEL=9 -cutline $SHPFILE $FILE $OUTFILE
 fi

done
