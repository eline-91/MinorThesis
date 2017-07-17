#!/bin/bash

# set path for output files here
DIR_OUT='/home/eline91/shared/userdata3/cleanFiles_clipCompleteArea'

for FILE in *.tif
do
 FILENEW=`echo $FILE | sed "s/.tif/_compND.tif/"`
 OUTFILE="$DIR_OUT/$FILENEW"
 if [ -f "$OUTFILE" ]
 then
 	echo "$OUTFILE exists, continue processing next file."
 else
	echo "$OUTFILE does not exists. Processing file...."
	gdal_translate -of GTiff -a_nodata 0 -co SPARSE_OK=TRUE -co INTERLEAVE=PIXEL -co COMPRESS=DEFLATE -co ZLEVEL=9 -co NBITS=11 -co NUM_THREADS=4 -ot UInt16 $FILE $OUTFILE
	rm $FILE
 fi

done
