#!/usr/bin/env Rscript

# This script defines changed pixels, performs predictions on these pixels using the same
# random forest model used to classify the basemap and updates the basemap.
# Before updating, the algorithm checks whether illogical changes have occured. If so, 
# the basemap value is maintained.

# The result is a new classification, that is an update of the input basemap.

# Can be run via the command line, via for example:
# R --slave --no-restore --file=detectChange.R --args --pvalueRaster="../../../userdata3/output/changeDetection/NDVI_pValues.tif"

library(optparse)
library(probaV)
library(rgdal)
library(raster)
source("changeDetectionFunctions.R")
source("utils/loadData.R")
source("utils/SetTempPath.R")

# Command-line options
parser = OptionParser()
parser = add_option(parser, "--pvalueRaster", type="character", 
                    default="../../../userdata3/output/changeDetection/NDVI_pValues.tif",
                    help="Filepath of the p value raster. (Default: %default)", metavar="path")
parser = add_option(parser, "--threshold", type="double", metavar="number",
                    default=0.05,
                    help="Threshold to reject null hypothesis. (Default: %default)")
parser = add_option(parser, "--metricData", type="character", metavar="path",
                    default="../../../userdata3/output/harmonics/phase_amplitude_3y.tif",
                    help="Data of harmonic metrics of the third year (raster tiff file). (Default: %default)")
parser = add_option(parser, "--rf_model", type="character", 
                    default="../../../userdata3/output/models/randomForest_03082017.rds",
                    help="Path to random forest model rds file. (Default: %default)", metavar="path")
parser = add_option(parser, "--basemap", type="character", metavar="path",
                    default="../../../userdata3/output/predictions/predictions_rf_18072017_2_reclass.tif",
                    help="Path of the basemap to be updated. (Default: %default)")
parser = add_option(parser, "--outputDir", type="character", metavar="path",
                    default="../../../userdata3/output/changeDetection/",
                    help="Output directory. (Default: %default)")
parser = add_option(parser, "--predictedFilename", type="character", default="predictions_changedPixels.tif",
                    help="Output filename of the tif file with the predictions of the changed pixels. (Default: %default)",
                    metavar="filename")
parser = add_option(parser, "--updatedFilename", type="character", default="updated_map.tif",
                    help="Output filename of the updated map. (Default: %default)",
                    metavar="filename")
parser = add_option(parser, "--changedFilename", type="character", default="changedPixels.tif",
                    help="Output filename of the changed pixels file: no data is unchanged, 1 is changed. (Default: %default)",
                    metavar="filename")
parser = add_option(parser, "--cores", type="integer", metavar="integer",
                    default=16, help="Number of cores to use. (Default: %default)")

args = parse_args(parser)

define_filename = function (dir, fn) {
  if (!is.null(fn)) {
    return(paste0(dir, fn))
  } else {
    return(NULL)
  }
}

process_changes = function(pvalueRaster=args[['pvalueRaster']], threshold=args[['threshold']], 
                           metricData=args[['metricData']], rf_model=args[['rf_model']],
                           basemap=args[['basemap']],
                           outputDir=args[['outputDir']], predictedFilename=args[['predictedFilename']],
                           updateFilename=args[['updatedFilename']],
                           changedFilename=args[['changedFilename']], cores=args[['cores']]) {
  
  # Detect the change based on the result of the t tests.
  outputChange = define_filename(outputDir, changedFilename)
  pvalues = raster(pvalueRaster)
  print(paste0("Detecting changed pixels. Output: ", changedFilename))
  
  changed = detect_change(pvalues, threshold, outputChange)
  
  # Predict pixels that are defined as changed
  outputPred = define_filename(outputDir, predictedFilename)
  metrics = load_harmonicMetrics(metricData)
  rf = readRDS(rf_model)
  print(paste0("Predicting changed pixels. Output: ", predictedFilename))
  
  predicted = predict_changedPixels(metrics, changed, rf, outputPred, cores)
  
  # Update basemap, checking for illogical changes
  bmap = raster(basemap)
  print(paste0("Updating basemap. Output: ", updateFilename))
  
  updatedMap = update_basemap(bmap, predicted, cores)
  writeRaster(updatedMap, paste0(outputDir, updateFilename), overwrite=TRUE)
  
  return(updatedMap)
}

process_changes()