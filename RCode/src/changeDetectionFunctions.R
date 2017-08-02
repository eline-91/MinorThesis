library(raster)
source("utils/loadData.R")
source("utils/loadInfo.R")

detect_change = function(pvalueRaster, threshold, outputName) {
  changed = pvalueRaster
  values(changed)[values(changed) >= threshold] = NA
  values(changed)[is.na(values(changed)) == FALSE] = 1
  
  if (!is.null(outputName)) {
    writeRaster(changed, filename = outputName)
  }
  
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

update_basemap = function(basemap, predicted, cores) {
  
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
        updated = 99 #temp
      }
    }
    
    return(updated)
  }
  
  beginCluster(cores, nice = min(cores - 1, 19))
  newMap = clusterR(b, calc, args=list(fun=checker), export='mat')
  #newMap = calc(b, fun = checker)
  endCluster()
  
  return(newMap)
}

# r1 = raster(nrows=4, ncols=4)
# vals = rep(c(10,20,30,40),4)
# vals[2] = NA
# vals[7] = NA
# vals[13] = 10
# vals[14] = 20
# vals[15] = 60
# vals[16] = 80
# values(r1) = vals
# head(r1)
# 
# r2 = r1
# vals2 = vals
# vals2[7] = 50
# vals2[3] = NA
# vals2[13] = 10
# vals2[14] = 80
# vals2[15] = 40
# vals2[16] = 30
# values(r2) = vals2
# head(r2)
# 
# r3 = update_basemap(r1, r2, 4)
# head(r3)
