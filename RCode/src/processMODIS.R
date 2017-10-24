#!/usr/bin/env Rscript

# This script processes two MODIS years: 2012 and 2013

# R --slave --no-restore --file=processMODIS.R

library(rgdal)
library(raster)
library(tools)
source("utils/loadInfo.R")
source("utils/SetTempPath.R")
source("summarizeChange.R")
source("makeDF.R")

dataDir = info$folders$mod

# Open two latest dates
mod2012_fp = paste0(dataDir, "2012/", "mosaic_2012_harmonizedPV.tif")
mod2012 = raster(mod2012_fp)

mod2013_fp = paste0(dataDir, "2013/", "mosaic_2013_harmonizedPV.tif")
mod2013 = raster(mod2013_fp)

# Check for the types of change occurring using the same unique changes 
# algorithm used for the maps produced during this thesis

outputUniqueChange = paste0(dataDir, "MODIS-2012-2013", "_UniqueChanges.tif")
outputCSV = paste0(dataDir, "MODIS-2012-2013", "_info.csv")
print(paste0("Collecting change information. Output: ", basename(outputUniqueChange)))
print(paste0("Information also written in csv file to: ", basename(outputCSV)))

before_after = stack(mod2012, mod2013)

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

# Write the information to text file
uniqueDF = makeDF()
mergedDF = merge(uniqueDF, frequencies, by="UniqueValues", all.x=TRUE)
write.csv(mergedDF, outputCSV)