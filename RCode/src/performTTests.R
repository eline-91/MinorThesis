#!/usr/bin/env Rscript

# This script takes the mean of the first two years of data (first layer in the harmonic metrics dataset, made by 
# the getHarmonics.R script) and compares the mean of the third year of data (March 11th, 2016 until and including
# March 06th, 2017) to this by means of a one sample t-test.

# The result is a raster layer with p-values.

# Can be run via the command line, via for example:
# R --slave --no-restore --file=performTTests.R --args --outputFilename="NDVI_pValues.tif"

library(probaV)
library(raster)
library(optparse)
source("utils/SetTempPath.R")
source("utils/loadData.R")
source("utils/loadInfo.R")

# Command-line options
parser = OptionParser()
parser = add_option(parser, "--NDVI_Dir", type="character", default="../../../userdata3/NDVI_images/",
                    help="Directory of input NDVI files. (Default: %default)", metavar="path")
parser = add_option(parser, "--metricData", type="character", metavar="path",
                    default="../../../userdata3/output/harmonics/phase_amplitude.tif",
                    help="Data of harmonic metrics (raster tiff file). (Default: %default)")
parser = add_option(parser, "--outputDir", type="character", metavar="path",
                    default="../../../userdata3/output/changeDetection/",
                    help="Output directory. (Default: %default)")
parser = add_option(parser, "--outputFilename", type="character", default="NDVI_pValues.tif",
                    help="Output filename of the tif file with the NDVI based p-values. (Default: %default)",
                    metavar="filename")
parser = add_option(parser, "--cores", type="integer", metavar="integer",
                    default=16, help="Number of cores to use. (Default: %default)")

args = parse_args(parser)

perform_ttests = function(NDVI_dir=args[["NDVI_Dir"]], metricData=args[["metricData"]], 
                          outputDir=args[["outputDir"]], outputFilename=args[["outputFilename"]],
                          cores=args[["cores"]], ...) {
  
  # For temporary timing purposes
  print(paste0("Start time: ", Sys.time()))
  
  bandPattern = get_bandPattern()
  tile = get_tile()
  tempDir = get_tempDir()
  start_date = "2016-03-11"
  end_date = "2017-03-06"
  
  filePath_vrt = paste0(tempDir, "thirdYear.vrt")
  mean.ndvi = load_harmonicMetrics(metricData, only_mean = TRUE)

  vrt = timeVrtProbaV(NDVI_dir, pattern = bandPattern, vrt_name = filePath_vrt, tile = tile,
                      start_date = start_date, end_date = end_date, return_raster = TRUE, ...)
  
  t.stack = stack(mean.ndvi, vrt)
  #nlayers = length(t.stack@layers)
  
  t.tester = function(x) {
    try(answer <- t.test(x[2:length(x)], mu=x[1]), silent=TRUE)
    if (exists("answer")) {
      return(answer$p.value)
    }
    return(NA)
  }
  
  beginCluster(cores, nice = min(cores - 1, 19))
  p.valueRaster = clusterR(t.stack, calc, args=list(fun=t.tester))#, export='nlayers')
  endCluster()
  
  # For temporary timing purposes
  print(paste0("End time: ", Sys.time()))
  
  outName = paste0(outputDir, outputFilename)
  writeRaster(p.valueRaster, filename = outName)
  
  return(p.valueRaster)
}

perform_ttests()