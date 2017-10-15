#!/usr/bin/env Rscript

# This script defines changed pixels, performs predictions on these pixels using 
# the same random forest model as was used to classify the basemap and updates 
# the basemap. Before updating, the algorithm checks whether illogical changes 
# have occured. If so, the basemap value is maintained. It also does the updating
# without taking (il)logical changes into account.

# The result is a new classification, that is an update of the input basemap. It
# also gives an output of the update without taking (il)logical changes into account.
# Besides this, other rasters containing data on changed pixels and predicted
# pixels are written to the same folder. Also, the type of change is recorded
# via a unique identifier and written to a rasterfile, as well as a csv file. 
# This file also states the number of times each type of change occurred as well
# as whether the change is logical or not.

# Information and input taken from the configuration file:
# - the p-value raster
# - training rasters of the third year
# - the random forest model used for the basemap
# - the basemap needed to be updated
# - the filename of the updated basemap
# - the filename of the textfile with some statistics

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
source("summarizeChange.R")
source("makeDF.R")

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
  
  ### Step 1: detect the change based on the result of the t tests.
  pvalueRaster = info$changeDetection$pvalue_raster  
  outputChange = paste0(outDir, "/", baseFN, "_changedPix.tif")
  
  if (!file.exists(outputChange)) {
    pvalues = raster(pvalueRaster)
    print(paste0("Detecting changed pixels. Output: ", basename(outputChange)))
    changed = detect_change(pvalues, threshold, outputChange)
  } else {
    print(paste0(basename(outputChange), " already exists in this folder. Loading ", 
                 basename(outputChange)))
    changed = raster(outputChange)
  }
  
  ### Step 2: predict those pixels that are defined as changed
  outputPred = paste0(outDir, "/", baseFN, "_predictedPix.tif")
  # Load the training rasters belonging to the third year of data
  trainRasters = load_trainingRasters("3y")
  rf = readRDS(info$classification$rf_model)
  
  print(paste0("Predicting changed pixels. Output: ", basename(outputPred)))
  predicted = predict_changedPixels(trainRasters, changed, rf, outputPred, 
                                    cores)
  # Calculate count of changed pixels
  count_predicted = getCountValueChangedPixels(outputPred)
  
  ### Step 3: Calculate statistics
  outputUniqueChange = paste0(outDir, "/", baseFN, "_UniqueChanges.tif")
  outputInfo = paste0(outDir, "/", baseFN, "_info.txt")
  outputCSV = paste0(outDir, "/", baseFN, "_info.csv")
  print(paste0("Collecting change information. Output: ", basename(outputUniqueChange)))
  print(paste0("Information also written in text file to: ", basename(outputInfo)))
  print(paste0("Information also written in csv file to: ", basename(outputCSV)))

  basemap = raster(info$classification$basemap)
  previous = mask(basemap, predicted)
  before_after = stack(previous, predicted)
  
  if (!file.exists(outputUniqueChange)) {
    uniqueMap = collectStats(before_after)
    writeRaster(uniqueMap, filename = outputUniqueChange, datatype="INT2S", 
                progress='text')
  } else {
    print(paste0(basename(outputUniqueChange), " already exists in this folder. Loading ", 
                 basename(outputUniqueChange)))
    uniqueMap = raster(outputUniqueChange)
  }
  
  frequencies = as.data.frame(freq(uniqueMap, progress='text'))
  colnames(frequencies) = c("UniqueValues", "Count")
  
  # Write the information to text files
  write("Count of changed pixels: ", file = outputInfo)
  write(count_predicted, file = outputInfo, append = T)
  
  uniqueDF = makeDF()
  mergedDF = merge(uniqueDF, frequencies, by="UniqueValues", all.x=TRUE)
  write.csv(mergedDF, outputCSV)
  
  ### Step 4: update basemap, checking for illogical changes
  print(paste0("Updating basemap. Output: ", basename(outName_update)))
  
  if (!file.exists(outName_update)) {
    updatedMap = update_basemap(basemap, predicted)
    writeRaster(updatedMap, filename = outName_update, datatype = "INT2S", 
                progress='text')
  } else {
    print(paste0(basename(outName_update), " already exists in this folder."))
  }
  ### Step 5: update basemap, do not check for illogical changes
  outputNoL = paste0(outDir, "/", baseFN, "_withoutLogicalChanges.tif")
  print(paste0("Updating basemap without logical changes. Output: ", 
               basename(outputNoL)))
  
  if (!file.exists(outputNoL)) {
    updatedMapNoL = update_basemap_noLogical(basemap, predicted)
    writeRaster(updatedMapNoL, filename = outputNoL, datatype = "INT2S", 
                progress='text')
  } else {
    print(paste0(basename(outputNoL), " already exists in this folder."))
  }
}

process_changes()