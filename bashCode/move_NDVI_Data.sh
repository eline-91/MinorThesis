#!/bin/bash

# set path for output files here
DIR_IN='/home/eline91/shared/userdata3/cleanFiles/'
DIR_OUT='/home/eline91/shared/userdata3/NDVI_images'

for FILE in $DIR_IN*NDVI_sm.tif
do
 FILENAME=$(basename "$FILE")
 FILENEW=`echo $FILENAME | sed "s/.tif/_ts.tif/"`
 OUTFILE="$DIR_OUT/$FILENEW"
 if [ -f "$OUTFILE" ]
 then
 	echo "$OUTFILE exists, continue processing next file."
 else
	echo "$OUTFILE does not exists. Processing file...."
	cp $FILE $OUTFILE
 fi

done
