# This file contains functions to guide the change detection process. They are
# called from detectChange.R

library(raster)
library(ranger)
library(tools)
source("utils/loadInfo.R")
source("utils/SetTempPath.R")

# This function gives a value of 1 when the value of a pixel on a value
# raster has exceeded a certain threshold and gives the cell NA when it hasn't.
detect_change = function(raster, threshold, outputName) {
  changed = raster
  values(changed)[values(changed) >= threshold] = NA
  values(changed)[is.na(values(changed)) == FALSE] = 1
  
  writeRaster(changed, filename = outputName, overwrite=TRUE, datatype="INT2S")
  
  return(changed)
}

# This function performs the predictions on those pixels that are flagged as
# changed and reclassifies them to the lc codes
predict_changedPixels = function(trainRasters, changed_mask, rf_model, 
                                 outputName, cores) {
  
  RP = function(...)
  {
    psnice(value = min(cores - 1, 19))
    rp = predict(...)
    return(rp$predictions)
  }
  
  if (!file.exists(outputName)) {
    # Load harmonic metrics of the third year
    changed_rasters = mask(trainRasters, changed_mask)
    
    print("Predicting...")
    print(system.time(predicted <- predict(changed_rasters, rf_model, fun=RP, 
                                           num.threads=cores, progress="text")))
    
    # Print unique values of predicted raster
    print(paste0("Unique values of predicted: ", unique(predicted)))
    
    print("Reclassifying...")
    mat = get_reclassMatrix()
    reclass = reclassify(x=predicted, rcl=mat, filename=outputName, 
                         datatype="INT2S")
    print(paste0("Unique values of reclassified: ", unique(reclass)))
    return(reclass)
    
  } else {
    print(paste0(basename(outputName), " already exists in this folder. Loading ", 
                 basename(outputName)))
    ras = raster(outputName)
    return(ras)
  }
}


# This function updates the basemap, keeping into consideration illogical
# changes.
update_basemap = function(basemap, predicted) {
  
  # For timing purposes
  print(paste0("Start time: ", Sys.time()))
  
  b = brick(basemap, predicted)
  mat = get_illogicalChanges()
  
  # Helper function that checks whether an illogical change has occured or not
  # and makes a decision on which value to keep (basemap or predicted)
  checker = function(x) {
    
    # Situation 1: basemap is NA, predicted is not > change to predicted
    # Situation 2: basemap has value, predicted is NA > keep basemap value
    # Situation 3: both have values, check illogical changed matrix
    # Situation 4: both are NA, keep NA
    
    if (is.na(x[1]) && !is.na(x[2])) {
      updated=x[2]
    } else if (!is.na(x[1]) && is.na(x[2])) {
      updated=x[1]
    } else if (is.na(x[1]) && is.na(x[2])) {
      updated=NA
    } else if (!is.na(x[1]) && !is.na(x[2])){
      illog = mat[toString(x[1]), toString(x[2])]
      if (illog == 1) { # illogical transition, keep basemap value
        updated = x[1]
      } else if (illog == 0) { # possible transition, update basemap value
        updated = x[2]
      } else {
        updated = 99 # To check for unaccounted for situations (value should not be present!)
      }
    }
    return(updated)
  }
  
  newMap = calc(b, fun = checker)
  
  # For timing purposes
  print(paste0("End time: ", Sys.time()))
  
  return(newMap)
}

# This function updates the basemap, but does not take illogical changes into
# account.
update_basemap_noLogical = function(basemap, predicted) {
  
  # For timing purposes
  print(paste0("Start time: ", Sys.time()))
  
  b = brick(basemap, predicted)
  
  # Helper function that checks to which value to update
  checker = function(x) {
    
    # Situation 1: basemap is NA, predicted is not > change to predicted
    # Situation 2: basemap has value, predicted is NA > keep basemap value
    # Situation 3: both have values, update to predicted
    # Situation 4: both are NA, keep NA
    
    if (is.na(x[1]) && !is.na(x[2])) {
      updated=x[2]
    } else if (!is.na(x[1]) && is.na(x[2])) {
      updated=x[1]
    } else if (is.na(x[1]) && is.na(x[2])) {
      updated=NA
    } else if (!is.na(x[1]) && !is.na(x[2])){
      updated=x[2]
    }
    return(updated)
  }
  
  newMap = calc(b, fun = checker)
  
  # For timing purposes
  print(paste0("End time: ", Sys.time()))
  
  return(newMap)
}
