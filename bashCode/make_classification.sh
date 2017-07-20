#!/bin/bash

# Variables
RF="../../../userdata3/output/models/randomForest_19072017.rds"

# First peform classification
R --slave --no-restore --file=classify.R --args --outputName="randomForest_19072017"

# Then perform predictions
R --slave --no-restore --file=predict.R --args --rf_modelPath=$RF --outputName="predictions_rf_19072017"
