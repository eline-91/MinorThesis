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

# Command-line options
parser = OptionParser()
parser = add_option(parser, "--trainingData", type="character", 
                    default="../../../userdata3/TrainingData/TotalTrainingData_080617.csv",
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

# For testing purposes
trainingData <- "../../../userdata3/TrainingData/TotalTrainingData_080617.csv"
metricData <- "../../../userdata3/output/harmonics/phase_amplitude.tif"


classify_rf <- function(trainingData=args[["trainingData"]], metricData=args[["metricData"]], 
                     outputDir=args[["outputDir"]], outputName=args[["outputName"]]) {
  
  trainingPoints <- read.csv(trainingData, header = TRUE)
  coordinates(trainingPoints) <- ~X+Y
  projection(trainingPoints) <- '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'
  
  trainingRasters <- brick(metricData)
  
  df_train <- extract(trainingRasters, trainingPoints, cellnumbers=T, df=T)
  df_train  <- na.exclude(df_train)
  
  df_ref <- trainingPoints@data[df_train$ID,]
  df_model <- cbind(code=df_ref$class_code, df_train)
  df_model <- cbind(lc=df_ref$class_name, df_model)
  df_model$lc <- as.factor(df_model$lc)
  
  cc <- complete.cases(df_model)
  print(table(df_model$lc[cc]))
  
  rf <- ranger(lc ~ ., df_model[cc, -(2:4)], num.trees=500, write.forest=T,
               probability = F, num.threads=10, verbose=T, importance = "impurity")
  
  saveRDS(rf, paste0(outputDir, outputName, ".rds"))
  
  return(rf)
}

classify_rf()