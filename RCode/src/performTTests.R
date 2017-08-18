#!/usr/bin/env Rscript

# This script takes the mean of the first two years of data and compares the 
# mean of the third year of data (March 11th, 2016 until and including
# March 06th, 2017) to this by means of a one sample t-test. 

# Information in configuration file:
# - NDVI input directory
# - band pattern and tile information
# - temporary directory
# - start and end date of the third year
# - location of the harmonic metrics of the first two years
# - output filename of the p-value raster

# The result is a raster layer with p-values.

# Can be run via the command line, via for example:
# R --slave --no-restore --file=performTTests.R --args --cores=16

library(probaV)
library(raster)
library(optparse)
source("utils/SetTempPath.R")
source("utils/loadData.R")
source("utils/loadInfo.R")

# Command-line options
parser = OptionParser()
parser = add_option(parser, "--cores", type="integer", metavar="integer",
                    default=16, help="Number of cores to use. (Default: %default)")

args = parse_args(parser)

perform_ttests = function(cores=args[["cores"]], ...) {
  
  # For timing purposes
  print(paste0("Start time: ", Sys.time()))
  
  # Get necessary information and input
  NDVI_dir = info$folders$NDVI_images
  bandPattern = info$dataset$bandPattern
  tile = info$dataset$tile
  tempDir = info$folders$temp
  
  start_date = info$dataset$start_3y
  end_date = info$dataset$end_3y
  filePath_vrt = paste0(tempDir, "thirdYear.vrt")
  
  # Load mean NDVI of the first two years
  mean.ndvi.2y = load_harmonicMetrics("2y", only_mean = TRUE)
  
  # Create virtual raster brick of the third year
  vrt = timeVrtProbaV(NDVI_dir, pattern = bandPattern, vrt_name = filePath_vrt, 
                      tile = tile, start_date = start_date, end_date = end_date, 
                      return_raster = TRUE, ...)
  
  # Stack mean and vrt of third year
  t.stack = stack(mean.ndvi.2y, vrt)
  
  # Helper function to perform t-test
  t.tester = function(x) {
    try(answer <- t.test(x[2:length(x)], mu=x[1]), silent=TRUE)
    if (exists("answer")) {
      return(answer$p.value)
    }
    return(NA)
  }
  
  # Allow to process this on multiple cores
  beginCluster(cores, nice = min(cores - 1, 19))
  p.valueRaster = clusterR(t.stack, calc, args=list(fun=t.tester))
  endCluster()
  
  outName = info$changeDetection$pvalue_raster
  writeRaster(p.valueRaster, filename = outName, overwrite=TRUE)
  
  # For timing purposes
  print(paste0("End time: ", Sys.time()))
  
  return(p.valueRaster)
}

perform_ttests()