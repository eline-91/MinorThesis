# This script summarizes the information on (il)logical changes. It gives a 
# unique value to each change.

library(raster)
source("utils/loadInfo.R")

# This function counts the number of changed pixels
getCountValueChangedPixels = function(filePath) {
  r = raster(filePath)
  f = freq(r, useNA = 'no', progress='text')
  s = sum(f[,2])
  return(s)
}

# This funtion collects the unique change value of each pixel and saves it in
# a raster.
collectStats = function(rasterStack) {
  mat = get_illogicalChanges()
  uniqueMat = get_uniqueChanges()
  
  # Helper function that checks whether an illogical change has occured or not
  # and makes a decision on which value to keep (basemap or predicted)
  checker = function(x) {
    
    # Situation 1: basemap is NA, predicted is not > not counted: 99
    # Situation 2: basemap has value, predicted is NA > not counted: 99
    # Situation 3: both have values, check illogical changed matrix and give a
    #              unique value per change
    # Situation 4: both are NA > not counted: 99
    
    if (is.na(x[1]) && !is.na(x[2])) {
      updated=99
    } else if (!is.na(x[1]) && is.na(x[2])) {
      updated=99
    } else if (is.na(x[1]) && is.na(x[2])) {
      updated=99
    } else if (!is.na(x[1]) && !is.na(x[2])){
      illog = mat[toString(x[1]), toString(x[2])]
      updated = uniqueMat[toString(x[1]), toString(x[2])]
    }
    return(updated)
  }
  
  uniqueMap = calc(rasterStack, fun = checker)
  return(uniqueMap)
}