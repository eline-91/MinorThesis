#!/bin/bash

# Change directory to inside the R src folder and then run this file
# Most parameters that are used in these functions can be edited in the 
# configuration.yaml file.

# This file takes very long to run, and is therefore meant more as documentation
# on the order of the different scripts.

# Fixed variables
CORES=16

# Classification of the first two years
# Step 1: make random forest model
R --slave --no-restore --file=classify.R --args --cores=$CORES

# Step 2: use random forest model to predict basemap
R --slave --no-restore --file=predict.R --args --cores=$CORES

# Step 3: cross-validate basemap
R --slave --no-restore --file=crossValidation.R --args --folds=5

# Detect change and update basemap
# Step 4: calculate harmonic metrics of the third year
R --slave --no-restore --file=getHarmonics.R --args --version="3y" --order=2 --rowsPerThread=14 --cores=$CORES

# Step 5: calculate median min-max for the third year
R --slave --no-restore --file=calc_minmax_indices.R --args --version="3y" --cores=16

# Step 6: perform t-test to compare third year with first two years
R --slave --no-restore --file=performTTests.R --args --cores=$CORES

# Step 7: detect change, and update basemap 
R --slave --no-restore --file=detectChange.R --args --threshold=0.05 --cores=$CORES