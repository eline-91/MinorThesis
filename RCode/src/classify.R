#!/usr/bin/env Rscript

# This script makes a random forest model based on harmonic metric and elevation 
# data and a point training dataset, and saves the rf model to disk as a .rds 
# file.

# Information in configuration file:
# - location of the training variables csv file
# - output filename of the random forest model

# Can be run via the command line, via for example:
# R --slave --no-restore --file=classify.R --args --cores=16

library(ranger)
library(probaV)
library(raster)
library(optparse)
source("utils/SetTempPath.R")
source("utils/loadData.R")
source("utils/loadInfo.R")

# Command-line options
parser = OptionParser()
parser = add_option(parser, "--cores", type="integer", default=16,
                    help="Number of cored to use. (Default: %default)", 
                    metavar="integer")
args = parse_args(parser)

classify_rf = function(cores=args[["cores"]]) {
  
  outputFile = info$classification$rf_model
  
  # Check if file already exists, if not make it
  if (!file.exists(outputFile)) {
    
    # Load the training variables (from the csv file)
    df_model = load_trainingData()
    cc = complete.cases(df_model)
    print(table(df_model$class.name[cc]))
  
    rf = ranger(class.name ~ ., df_model[cc, -(c(1,3))], num.trees=500, 
                write.forest=T, probability = F, num.threads=cores, verbose=T, 
                importance = "impurity")
    
    # Save random forest model to file
    saveRDS(rf, outputFile)
    return(rf)
    
  } else {
    print(paste0(basename(outputFile), " already exists in this folder."))
  }
}

classify_rf()