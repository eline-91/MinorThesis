#!/usr/bin/env Rscript

# This script takes a random forest model based on harmonic metric data and performs the
# predictions, reclassifies the values to their proper lc codes, and 
# writes the resulting raster as a tif file to disk.

# Function RP is taken from code made by Dainius Masiliunas:
# https://github.com/GreatEmerald/master-classification/blob/master/src/classification/predict-rf.r

# Can be run via the command line, via for example:
# R --slave --no-restore --file=predict.R --args --rf_modelPath="../../../userdata3/output/models/randomForest_18072017_2.rds" --outputName="predictions_rf_date"

library(ranger)
library(tools)
library(raster)
library(optparse)
source("utils/SetTempPath.R")
source("utils/loadInfo.R")
source("utils/loadData.R")

# Command-line options
parser = OptionParser()
parser = add_option(parser, "--rf_modelPath", type="character", 
                    default=NULL,
                    help="Path to random forest model rds file.", metavar="path")
parser = add_option(parser, "--metricData", type="character", metavar="path",
                    default="../../../userdata3/output/harmonics/phase_amplitude.tif",
                    help="Data of harmonic metrics (raster tiff file). (Default: %default)")
parser = add_option(parser, "--outputDir", type="character", metavar="path", 
                    default="../../../userdata3/output/predictions/", 
                    help="Output directory to store random forest model predictions. (Default: %default)")
parser = add_option(parser,"--outputName", type="character", metavar="filename", default = NULL,
                    help="Filename of the predicted raster (no extension).")
parser = add_option(parser,"--cores", type="integer", metavar="integer", default=16,
                    help="Number of cores to use. (Default: %default)")

args = parse_args(parser)

predict_rf = function(rf_modelPath=args[["rf_modelPath"]], metricData=args[["metricData"]], 
                       outputDir=args[["outputDir"]], outputName=args[["outputName"]], 
                       cores=args[["cores"]]) {
  
  metrics = load_harmonicMetrics(metricData)
  rfmodel = readRDS(rf_modelPath)
  
  RP = function(...)
  {
    psnice(value = min(cores - 1, 19))
    rp = predict(...)
    return(rp$predictions)
  }
  
  outputFile = paste0(outputDir, outputName, ".tif")
  
  if (!file.exists(outputFile)) {
    print("Predicting...")
    print(system.time(predicted = predict(metrics, rfmodel, fun=RP, num.threads=cores,
                                          progress="text")))
    
    print("Reclassifying...")
    mat = get_reclassMatrix()
    reclass = reclassify(x=predicted, rcl=mat, filename=outputFile)
    return(reclass)
    
  } else {
    print(paste0(outputName, " already exists in this folder."))
  }
}

predict_rf()