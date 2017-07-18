#!/usr/bin/env Rscript

library(ranger)
library(tools)
library(raster)
library(optparse)
source("utils/SetTempPath.R")
#"../../../userdata3/output/models/randomForest_18072017_2.rds"
# Command-line options
parser = OptionParser()
parser = add_option(parser, "--rf_modelPath", type="character", 
                    default="../../../userdata3/output/models/randomForest_18072017_2.rds",
                    help="Path to random forest model rds file. (Default: %default)", metavar="path")
parser = add_option(parser, "--metricData", type="character", metavar="path",
                    default=NULL,
                    help="Data of harmonic metrics (raster tiff file). (Default: %default)")
parser = add_option(parser, "--outputDir", type="character", metavar="path", 
                    default="../../../userdata3/output/predictions/", 
                    help="Output directory to store random forest model predictions. (Default: %default)")
parser = add_option(parser,"--outputName", type="character", metavar="filename", default = NULL,
                    help="Filename of the predicted raster (no extension).")
parser = add_option(parser,"--cores", type="integer", metavar="integer", default=16,
                    help="Number of cores to use. (Default: %default)")

args = parse_args(parser)

predict_rf <- function(rf_modelPath=args[["rf_modelPath"]], metricData=args[["metricData"]], 
                       outputDir=args[["outputDir"]], outputName=args[["outputName"]], 
                       cores=args[["cores"]]) {
  
  
  
  
}

cores = 16
outputDir = "../../../userdata3/output/predictions/"
outputName = "predictions_rf_18072017"
dataDir <-"../../../userdata3/output/models/"

harmonics = brick("../../../userdata3/output/harmonics/phase_amplitude.tif")
rfmodel = readRDS(paste0(dataDir, "randomForest_18072017.rds"))

RP = function(...)
{
  psnice(value = min(cores - 1, 19))
  rp = predict(...)
  return(rp$predictions)
}

print(system.time(predicted <- predict(harmonics, rfmodel, fun=RP, num.threads=cores,
                                       filename=paste0(outputDir, outputName, ".tif"), 
                                       progress="text", overwrite=TRUE)))