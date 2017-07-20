#!/usr/bin/env Rscript

# This script makes a random forest model based on harmonic metric data and a
# point training dataset, and saves the rf model to disk as a .rds file.

# Can be run via the command line, via for example:
# R --slave --no-restore --file=classify.R --args --outputName="randomForest_date"

library(ranger)
library(probaV)
library(raster)
library(optparse)
source("utils/SetTempPath.R")
source("utils/loadData.R")

# Command-line options
parser = OptionParser()
parser = add_option(parser, "--trainingData", type="character", 
                    default="../../../userdata3/TrainingData/TrainingData_variables.csv",
                    help="Path to training pixels csv file. (Default: %default)", metavar="path")
parser = add_option(parser, "--metricData", type="character", metavar="path",
                    default="../../../userdata3/output/harmonics/phase_amplitude.tif",
                    help="Data of harmonic metrics (raster tiff file). (Default: %default)")
parser = add_option(parser, "--outputDir", type="character", metavar="path", 
                    default="../../../userdata3/output/models/", 
                    help="Output directory to store random forest models. (Default: %default)")
parser = add_option(parser,"--outputName", type="character", metavar="filename", default = "randomForest",
                    help="Filename of the random forest model (no extension).")

args = parse_args(parser)

classify_rf = function(trainingData=args[["trainingData"]], metricData=args[["metricData"]], 
                     outputDir=args[["outputDir"]], outputName=args[["outputName"]]) {
  
  outputFile = paste0(outputDir, outputName, ".rds")
  
  if (!file.exists(outputFile)) {
    df_model = load_trainingData(trainingData = trainingData)
  
    cc = complete.cases(df_model)
    print(table(df_model$class.name[cc]))
  
    rf = ranger(class.name ~ ., df_model[cc, -(c(1,3))], num.trees=500, write.forest=T,
                probability = F, num.threads=10, verbose=T, importance = "impurity")
  
    saveRDS(rf, outputFile)
    return(rf)
    
  } else {
    print(paste0(outputName, " already exists in this folder."))
  }
}

classify_rf()