# This script extracts for each training location the corresponding data from
# the harmonic metrics and DEM derivatives datasets, and merges them together.
# The result is written to a csv file.

# Information needed from configuration file:
# - location of the ground truth data
# - location of the harmonic metrics of the first two years
# - location of the DEM variables tif file
# - output csv location

library(raster)
source("utils/SetTempPath.R")
source("utils/loadData.R")
source("utils/loadInfo.R")

merge_data = function() {
  
  groundData = load_groundData()
  rasters = load_trainingRasters(version="2y")
  
  data = extract(rasters, groundData, method = "simple", cellnumbers=T, sp=T)
  print(anyNA(data@data))
  
  write.csv(data, info$classification$training_variables)
  
}

merge_data()
