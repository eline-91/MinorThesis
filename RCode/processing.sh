#!/bin/bash

# Change directory to the location of the R folders and then run this file

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

# Step 5: perform t-test to compare third year with first two years
R --slave --no-restore --file=performTTests.R --args --cores=$CORES

# Step 6: detect change, and update basemap 
R --slave --no-restore --file=detectChange.R --args --threshold=0.05 --cores=$CORES