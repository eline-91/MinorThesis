#!/bin/bash

# Change directory to inside the R src folder and then run this file
# Most parameters that are used in these functions can be edited in the 
# configuration.yaml file.

# This file takes very long to run, and is therefore meant more as documentation
# on the order of the different scripts.

# Fixed variables
CORES=16

# Step 1: get the NDVI data and clean them.
R --slave --no-restore --file=CleanData_NDVI.R

# Step 2: move the NDVI data to its own location
extra/move_NDVI_Data.sh

# Step 3: get the harmonic metrics of the first two year of data
R --slave --no-restore --file=getHarmonics.R --args --version="2y" --order=2 --rowsPerThread=14 --cores=$CORES

# Step 4: download and preprocess the DEM, and calculate DEM derivatives
R --slave --no-restore --file=getDem.R

# Step 5: merge training data with the all training rasters (harmonic metrics
#         and DEM derivatives)
R --slave --no-restore --file=mergeTrainData.R

# Step 6 (optional): visualise the harmonic curves per class
R --slave --no-restore --file=visualiseHarmonics.R