#!/bin/bash

# set variables for bounding box coordinates here
# minimum latitude  (min y value)
LAT_MIN=7.97767857168254
# minimum longitude ( min x value)
LON_MIN=-11.19097222247619
# maximum latitude  (max y value)
LAT_MAX=10.04117063517460
# maximum longitude (max x value)
LON_MAX=-10.00049603200000

# set path for output files here
DIR_OUT='/home/eline91/shared/userdata3/cleanFiles_testArea'

for FILE in *V101.tif
do
 FILENEW=`echo $FILE | sed "s/.tif/_testArea.tif/"`
 OUTFILE="$DIR_OUT/$FILENEW"
 if [ -f "$OUTFILE" ]
 then
 	echo "$OUTFILE exists, continue processing next file."
 else
	echo "$OUTFILE does not exists. Processing file...."
	gdalwarp -te $LON_MIN $LAT_MIN $LON_MAX $LAT_MAX $FILE $OUTFILE
 fi

done
