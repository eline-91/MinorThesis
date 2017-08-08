library(raster)
library(ranger)
library(tools)
source("utils/loadInfo.R")
source("utils/SetTempPath.R")

detect_change = function(pvalueRaster, threshold, outputName) {
  changed = pvalueRaster
  values(changed)[values(changed) >= threshold] = NA
  values(changed)[is.na(values(changed)) == FALSE] = 1
  
  if (!is.null(outputName)) {
    writeRaster(changed, filename = outputName, overwrite=TRUE)
  }
  
  return(changed)
}

predict_changedPixels = function(metricData, changed_mask, rf_model, outputName, cores) {
  # Load harmonic metrics of the third year
  changed_harmonics = mask(metricData, changed_mask)
  
  RP = function(...)
  {
    psnice(value = min(cores - 1, 19))
    rp = predict(...)
    return(rp$predictions)
  }
  
  if (!file.exists(outputName)) {
    print("Predicting...")
    print(system.time(predicted <- predict(changed_harmonics, rf_model, fun=RP, num.threads=cores,
                                          progress="text")))
    
    # Print unique values of predicted raster
    print(paste0("Unique values of predicted: ", unique(predicted)))
    
    print("Reclassifying...")
    mat = get_reclassMatrix()
    reclass = reclassify(x=predicted, rcl=mat, filename=outputName)
    print(paste0("Unique values of reclassified: ", unique(reclass)))
    return(reclass)
    
  } else {
    print(paste0(outputName, " already exists in this folder. Loading ", outputName))
    ras = raster(outputName)
    return(ras)
  }
}


update_basemap = function(basemap, predicted, cores) {
  
  # For timing purposes
  print(paste0("Start time: ", Sys.time()))
  
  b = brick(basemap, predicted)
  mat = get_illogicalChanges()
  
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
