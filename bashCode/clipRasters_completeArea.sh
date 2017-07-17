#!/bin/bash

SHPFILE='/home/eline91/shared/userdata3/vectorData/AreaClip.shp'

# set path for output files here
DIR_OUT='/home/eline91/shared/userdata3/cleanFiles_clipCompleteArea'

for FILE in *V101.tif
do
 FILENEW=`echo $FILE | sed "s/.tif/_completeArea.tif/"`
 FILECHECK=`echo $FILE | sed "s/.tif/_completeArea_compND.tif/"`
 OUTFILE="$DIR_OUT/$FILENEW"
 CHECKFILE="$DIR_OUT/$FILECHECK"
 if [ -f "$CHECKFILE" ]
 then
 	echo "$OUTFILE exists, continue processing next file."
 else
	echo "$OUTFILE does not exists. Processing file...."
	gdalwarp -co SPARSE_OK=TRUE -co INTERLEAVE=PIXEL -co COMPRESS=DEFLATE -co ZLEVEL=9 -co NBITS=11 -co NUM_THREADS=4 -ot UInt16 -cutline $SHPFILE $FILE $OUTFILE
 fi

done
