#!/bin/bash

SHPFILE='/home/eline91/shared/userdata3/vectorData/AreaClip.shp'

# set path for output files here
DIR_OUT='/home/eline91/shared/userdata3/clip_SeparateLayers'

for FILE in *sm.tif
do
 FILENEW=`echo $FILE | sed "s/.tif/_temp.tif/"`
 FILEFINAL=`echo $FILE | sed "s/.tif/_clip.tif/"`
 OUTFILE="$DIR_OUT/$FILENEW"
 OUTFILEFINAL="$DIR_OUT/$FILEFINAL"
 if [ -f "$OUTFILE" ]
 then
 	echo "$OUTFILE exists, continue processing next file."
 else
	echo "$OUTFILE does not exists. Processing file...."
	gdalwarp -co SPARSE_OK=TRUE -co INTERLEAVE=PIXEL -co COMPRESS=DEFLATE -co ZLEVEL=9 -co NBITS=12 -co NUM_THREADS=6 -ot UInt16 -cutline $SHPFILE $FILE $OUTFILE
	gdal_translate -of GTiff -a_nodata 0 -co SPARSE_OK=TRUE -co INTERLEAVE=PIXEL -co COMPRESS=DEFLATE -co ZLEVEL=9 -co NBITS=12 -co NUM_THREADS=6 -ot UInt16 $OUTFILE $OUTFILEFINAL
	rm $OUTFILE
 fi

done
