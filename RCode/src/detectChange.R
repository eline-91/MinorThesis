#!/usr/bin/env Rscript

# This script defines changed pixels, performs predictions on these pixels using 
# the same random forest model as was used to classify the basemap and updates 
# the basemap.Before updating, the algorithm checks whether illogical changes 
# have occured. If so, the basemap value is maintained.

# The result is a new classification, that is an update of the input basemap.
# Besides this, other rasters containing data on changed pixels and predicted
# pixels are written to the same folder.

# Information and input taken from the configuration file:
# - the p-value raster
# - training rasters of the third year
# - the random forest model used for the basemap
# - the basemap needed to be updated
# - the filename of the updated basemap

# Can be run via the command line, via for example:
# R --slave --no-restore --file=detectChange.R --args --threshold=0.05 --cores=16

library(optparse)
library(probaV)
library(rgdal)
library(raster)
library(tools)
source("changeDetectionFunctions.R")
source("utils/loadData.R")
source("utils/loadInfo.R")
source("utils/SetTempPath.R")

# Command-line options
parser = OptionParser()
parser = add_option(parser, "--threshold", type="double", metavar="number",
                    default=0.05,
                    help="Threshold to reject null hypothesis. (Default: %default)")
parser = add_option(parser, "--cores", type="integer", metavar="integer",
                    default=16, help="Number of cores to use. (Default: %default)")

args = parse_args(parser)

process_changes = function(threshold=args[['threshold']], cores=args[['cores']]) {
  
  # Get filename output and output directory
  outName_update = info$changeDetection$updated_basemap
  outDir = dirname(outName_update)
  baseFN = file_path_sans_ext(basename(outName_update))
  
  # Step 1: detect the change based on the result of the t tests.
  pvalueRaster = info$changeDetection$pvalue_raster  
  outputChange = paste0(outDir, "/", baseFN, "_changedPix.tif")
  
  pvalues = raster(pvalueRaster)
  print(paste0("Detecting changed pixels. Output: ", basename(outputChange)))
  changed = detect_change(pvalues, threshold, outputChange)
  
  # Step 2: predict those pixels that are defined as changed
  outputPred = paste0(outDir, "/", baseFN, "_predictedPix.tif")
  # Load the training rasters belonging to the third year of data
  trainRasters = load_trainingRasters("3y")
  rf = readRDS(info$classification$rf_model)
  
  print(paste0("Predicting changed pixels. Output: ", basename(outputPred)))
  predicted = predict_changedPixels(trainRasters, changed, rf, outputPred, 
                                    cores)
  
  # Step 3: update basemap, checking for illogical changes
  basemap = raster(info$classification$basemap)
  
  print(paste0("Updating basemap. Output: ", basename(outName_update)))
  
  updatedMap = update_basemap(basemap, predicted)
  writeRaster(updatedMap, filename = outName_update, datatype = "INT2S", overwrite=TRUE)
  
  return(updatedMap)
}

process_changes()