#!/bin/bash

SHPFILE='/home/eline91/shared/userdata3/vectorData/AreaC.shp'

# set path for output files here
DIR_OUT='/home/eline91/shared/userdata3/AreaC'

for FILE in *NDVI_sm_ts.tif
do
 FILEFINAL=`echo $FILE | sed "s/sm_ts.tif/areaC.tif/"`
 OUTFILEFINAL="$DIR_OUT/$FILEFINAL"
 if [ -f "$OUTFILEFINAL" ]
 then
 	echo "$OUTFILEFINAL exists, continue processing next file."
 else
	echo "$OUTFILEFINAL does not exists. Processing file...."
	gdalwarp -cutline $SHPFILE -co "TILED=YES" -co "COMPRESS=LZW" -crop_to_cutline $FILE $OUTFILEFINAL
 fi

done
