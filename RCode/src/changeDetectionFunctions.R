library(raster)
source("utils/loadData.R")
source("utils/loadInfo.R")

detect_change = function(pvalueRaster, threshold, outputName) {
  changed = pvalueRaster
  values(changed)[values(changed) >= threshold] = NA
  values(changed)[is.na(values(changed)) == FALSE] = 1
  
  writeRaster(changed, filename = outputName)
  
  return(changed)
}

predict_changedPixels = function(metricData, changed_mask, rf_model, outputName, cores) {
  # Load harmonic metrics of the third year
  harmonics = load_harmonicMetrics(metricData)
  
  changed_harmonics = mask(harmonics, changed_mask)
  rfmodel = readRDS(rf_modelPath)
  
  RP = function(...)
  {
    psnice(value = min(cores - 1, 19))
    rp = predict(...)
    return(rp$predictions)
  }
  
  if (!file.exists(outputName)) {
    print("Predicting...")
    print(system.time(predicted = predict(changed_harmonics, rfmodel, fun=RP, num.threads=cores,
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

type_of_change = function() {
  
  
}

check_logicality = function() {
  
  
}


r <- raster(ncols=36, nrows=18)
r[] <- 1:ncell(r)/5000
head(r)
ch = detect_change(r, 0.05)
head(ch)
