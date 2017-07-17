#!/bin/bash

SHPFILE='/home/eline91/shared/userdata3/vectorData/AreaClip.shp'

# set path for output files here
DIR_OUT='/home/eline91/shared/userdata3/clip_NDVI'

for FILE in *NDVI_sm.tif
do
 FILENEW=`echo $FILE | sed "s/.tif/_temp.tif/"`
 FILEFINAL=`echo $FILE | sed "s/.tif/_clip.tif/"`
 OUTFILE="$DIR_OUT/$FILENEW"
 OUTFILEFINAL="$DIR_OUT/$FILEFINAL"
 if [ -f "$OUTFILE" ]
 then
 	echo "$OUTFILEFINAL exists, continue processing next file."
 else
	echo "$OUTFILEFINAL does not exists. Processing file...."
	gdalwarp -cutline $SHPFILE $FILE $OUTFILE
	gdal_translate -of GTiff -a_nodata -3.4e+38 $OUTFILE $OUTFILEFINAL
	#rm $OUTFILE
 fi

done
