#!/bin/bash

# set path for output files here
DIR_OUT='/home/eline91/shared/userdata3/cleanFiles_completeArea'

for FILE in *V101.tif
do
 FILENEW=`echo $FILE | sed "s/.tif/_completeArea.tif/"`
 OUTFILE="$DIR_OUT/$FILENEW"
 if [ -f "$OUTFILE" ]
 then
 	echo "$OUTFILE exists, continue processing next file."
 else
	echo "$OUTFILE does not exists. Processing file...."
	cp $FILE $OUTFILE
 fi

done
