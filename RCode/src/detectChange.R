source("changeDetectionFunctions.R")

define_filename = function (dir, fn) {
  if (!is.null(fn)) {
    return(paste0(dir, fn))
  } else {
    return(NULL)
  }
}

process_changes = function(pvalueRaster, threshold, metricData, rf_model, 
                           outputDir, predictedFilename, changedFilename=NULL, cores=16) {
  # Detect the change based on the result of the t tests.
  outputChange = define_filename(outputDir, changedFilename)
  changed = detect_change(pvalueRaster, threshold, outputChange)
  
  # Predict pixels that are defined as changed
  outputPred = define_filename(outputDir, predictedFilename)
  predicted = predict_changedPixels(metricData, changed, rf_model, outputPred, cores)
  
  
  
  
}

process_changed()