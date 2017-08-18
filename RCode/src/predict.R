#!/usr/bin/env Rscript

# This script takes a random forest model based on harmonic metric and elevation 
# data andperforms the predictions, reclassifies the values to their proper lc 
# codes and writes the resulting raster as a tif file to disk.

# Function RP is taken from code made by Dainius Masiliunas:
# https://github.com/GreatEmerald/master-classification/blob/master/src/classification/predict-rf.r

# Information in configuration file:
# - location of the harmonic metrics of the first two years
# - location of the DEM variables
# - location of the random forest model rds file
# - the class codes
# - output filename of the basemap

# Can be run via the command line, via for example:
# R --slave --no-restore --file=predict.R --args --cores=16

library(ranger)
library(tools)
library(raster)
library(optparse)
source("utils/SetTempPath.R")
source("utils/loadInfo.R")
source("utils/loadData.R")

# Command-line options
parser = OptionParser()
parser = add_option(parser,"--cores", type="integer", metavar="integer", default=16,
                    help="Number of cores to use. (Default: %default)")

args = parse_args(parser)

predict_rf = function(cores = args[["cores"]]) {
  
  # Load the rasters used for training and predicting the basemap (harmonic 
  # metrics and elevation data) and the random forest model
  trainingRasters = load_trainingRasters(version="2y")
  rfmodel = readRDS(info$classification$rf_model)
  
  RP = function(...)
  {
    psnice(value = min(cores - 1, 19))
    rp = predict(...)
    return(rp$predictions)
  }
  
  # Load output filepath from the configuration file.
  outputFile = info$classification$basemap
  
  # Check if output file exists
  if (!file.exists(outputFile)) {
    print("Predicting...")
    
    # Record processing time while predicting, as it is a lengthy process
    print(system.time(predicted <- predict(trainingRasters, rfmodel, fun=RP, 
                                           num.threads=cores, progress="text")))
    
    # Reclassify the predicted raster to the proper lc codes, using the
    # reclassification matrix from the configuration file
    print("Reclassifying...")
    mat = get_reclassMatrix()
    reclass = reclassify(x=predicted, rcl=mat, filename=outputFile)
    return(reclass)
    
  } else {
    print(paste0(basename(outputFile), " already exists in this folder."))
  }
}

predict_rf()