#!/usr/bin/env Rscript

# R --slave --no-restore --file=detectAnomalies.R

library(probaV)
library(npphen)
library(parallel)
library(tools)
source("utils/SetTempPath.R")
source("utils/loadInfo.R")

# Take necessary parameters and information from the configuration file
inputDir = info$folders$areaC
bandPattern = "NDVI_areaC.tif$"
tile = info$dataset$tile
tempDir = info$folders$temp

start_date_2y = info$dataset$start_date
end_date_2y = info$dataset$end_date

start_date_3y = info$dataset$start_3y
end_date_3y = info$dataset$end_3y

filePath_vrt = paste0(tempDir, "anomalies.vrt")

output_averaged = info$changeDetection$npphen_averaged
output_npphen = paste0(dirname(output_averaged), "/nnphen_completeOutput.tif")
format = "GTiff"
datatype = "FLT4S"

mc.cores = 26

print(paste0("Performing npphen algorithm and creating ", output_npphen, 
             " if this file does not exists."))
if (!file.exists(output_npphen)) {
  series = timeVrtProbaV(inputDir, pattern = bandPattern, vrt_name = filePath_vrt,
                        tile = tile, start_date = start_date_2y,
                        end_date = end_date_3y, return_raster = TRUE)

  # Helper function to perform PhenAnoma
  PhenAnomapper = function(x) {
    date_anomalies = readRDS("../data/dates_anomalies.rds")
    vec = PhenAnoma(x=x,dates=date_anomalies,h=1,refp=c(1:144), anop=c(145:215), 
                    rge = c(0,1))
    return(vec)
  }

  # For timing purposes
  print(paste0("Start time: ", Sys.time()))

  # Allow to process this on multiple cores
  beginCluster(mc.cores, nice = min(mc.cores - 1, 19))
  start = Sys.time()
  totMap = clusterR(series, calc, args=list(fun=PhenAnomapper))
  endCluster()

  # For timing purposes
  end = Sys.time()
  print(paste0("End time: ", Sys.time()))
  print(end-start)

  writeRaster(totMap, filename = output_npphen, progress="text")
  
} else {
  print(paste0(basename(output_npphen), " already exists in this folder. Loading ", 
               basename(output_npphen)))
  totMap = brick(output_npphen)
}

# Average the absolute anomaly values and write to raster
if (!file.exists(output_averaged)) {
  print(paste0("Computing the average, output: ", output_averaged))
  
  averaged = mean(abs(totMap), na.rm=T)
  
  writeRaster(averaged, filename = output_averaged, progress="text")
  
} else {
  print(paste0(basename(output_averaged), " already exists in this folder. Loading ", 
               basename(output_averaged)))
  averaged = raster(output_averaged)
}

detect_npphen_change = function(raster, threshold, outputName) {
  changed = raster
  values(changed)[values(changed) <= threshold] = NA
  
  writeRaster(changed, filename = outputName, overwrite=TRUE)
  
  return(changed)
}

# Use the averaged raster to select changed pixels based on a threshold
npphen_threshold = info$changeDetection$npphen_threshold
npphen_result = info$changeDetection$npphen_change
print(paste0("Using a threshold of ", npphen_threshold, ", change is detected and saved to: ",
             npphen_result))
npphen_changed = detect_npphen_change(raster = averaged, threshold = npphen_threshold,
                              outputName = npphen_result)