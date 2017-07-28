#!/usr/bin/env Rscript

# Code based on code written by Dainius Masiliunas (edited):
# https://github.com/GreatEmerald/master-classification/blob/master/src/optical/get-harmonics.r

# The input is a folder with cleaned NDVI files. The process cleans them again due to the 
# nature of the PROBA-V package. Output is two multi-band files with harmonic coefficients,
# one of which contains the phases and amplitudes of the data.

# Can be run via the command line, via for example:
# R --slave --no-restore --file=getHarmonics.R --args --start_date="2014-03-11" --end_date="2016-03-06"

# Some parameters are fixed in utils/loadInfo.R, and should be changed there. Among these parameters are:
# tile, band pattern, and temporary directory.

library(probaV)
library(tools)
library(optparse)
source("utils/SetTempPath.R")
source("utils/loadInfo.R")

# Command-line options
parser = OptionParser()
parser = add_option(parser, "--inputDir", type="character", default="../../../userdata3/NDVI_images/",
                    help="Directory of input files. (Default: %default)", metavar="path")
parser = add_option(parser, "--outputDir", type="character", metavar="path",
                    default="../../../userdata3/output/harmonics/",
                    help="Output directory. (Default: %default)")
parser = add_option(parser,"--start_date", type="character", metavar="date", default = NULL,
                    help="Start date of the time series. Format: 'yyyy-mm-dd'.")
parser = add_option(parser, "--end_date", type="character", metavar="date", default = NULL,
                    help="End date of the time series. Format: 'yyyy-mm-dd'.")
parser = add_option(parser, "--filenameHarm", type="character", default="harmonic_coefficients.tif",
                    help="Output filename of the tif file with the harmonic coefficients. (Default: %default)", 
                    metavar="filename")
parser = add_option(parser, "--filenamePA", type="character", default="phase_amplitude.tif",
                    help="Output filename of the tif file with the phase and amplitude. (Default: %default)", 
                    metavar="filename")
parser = add_option(parser, "--logFile", type="character", default="get_harmonics.log",
                    help="Output filename of the log file. (Default: %default)", 
                    metavar="filename")
parser = add_option(parser, "--order", type="integer", metavar="integer",
                    default=2, help="Order of the regression. Choose 1, 2 or 3. (Default: %default)")
parser = add_option(parser, "--rowsPerThread", type="integer", metavar="integer",
                    default=14, help="Number of rows to process per thread. (Default: %default)")
parser = add_option(parser, "--cores", type="integer", metavar="integer",
                    default=16, help="Number of cores to use. (Default: %default)")
# sink("/dev/null") # Silence rasterOptions
# parser = add_option(parser, c("-m", "--tempDir"), type="character", metavar="path",
#                     help=paste0("Path to a temporary directory to store results in. (Default: ",
#                                 rasterOptions()$tmpdir, ")"))
args = parse_args(parser)

get_harmonics = function(inputDir=args[["inputDir"]], outputDir=args[["outputDir"]], 
                          start_date=args[["start_date"]], end_date=args[["end_date"]],
                          outputFileHarm=args[["filenameHarm"]], outputFilePA=args[["filenamePA"]],
                          logFile=args[["logFile"]], order=args[["order"]],
                          rowsPerThread=args[["rowsPerThread"]], cores=args[["cores"]], ...) {
  
  bandPattern = get_bandPattern()
  tile = get_tile()
  tempDir = get_tempDir()
  
  
  filePath_harm = paste0(outputDir, outputFileHarm)
  filePath_pa = paste0(outputDir, outputFilePA)
  filePath_log = paste0(outputDir, logFile)
  filePath_vrt = paste0(tempDir, "harmonics.vrt")
  
  vrt = timeVrtProbaV(inputDir, pattern = bandPattern, vrt_name = filePath_vrt, tile = tile,
                      start_date = start_date, end_date = end_date, return_raster = TRUE, ...)
  
  ts = timeVrtProbaV(inputDir, pattern = bandPattern, vrt_name = filePath_vrt, tile = tile,
                     start_date = start_date, end_date = end_date, return_raster = FALSE, ...)
  
  if (!file.exists(filePath_harm)) {
    psnice(value = min(cores - 1, 19))
    system.time(coeffs = getHarmMetricsSpatial(vrt, ts, minrows = rowsPerThread, mc.cores = cores,
                                                logfile=filePath_log, overwrite=TRUE, filename = filePath_harm, 
                                                order = order, datatype="FLT4S", progress="text"))
    } else {
      print(paste(filePath_harm, "already exists.", sep=" "))
      coeffs = brick(filePath_harm)
    }
  
  phaser = function(co, si)
  {
    tau = 2*pi
    return(atan2(si, co) %% tau)
  }
  amplituder = function(co, si)
  {
    return(sqrt(co^2 + si^2))
  }
  
  # Order of parameters:
  # min max intercept co si co2 si2 trend
  p1 = overlay(coeffs[[4]], coeffs[[5]], fun=phaser)
  a1 = overlay(coeffs[[4]], coeffs[[5]], fun=amplituder)
  p2 = overlay(coeffs[[6]], coeffs[[7]], fun=phaser)
  a2 = overlay(coeffs[[6]], coeffs[[7]], fun=amplituder)
  
  beginCluster(cores, nice = min(cores - 1, 19))
  meanData = clusterR(vrt, calc, args=list(mean, na.rm=TRUE))
  endCluster()
  
  finalStack = stack(meanData, p1, a1, p2, a2)
  brick(finalStack, filename = filePath_pa, datatype = "FLT4S", overwrite = TRUE,
        progress = "text", options = c("COMPRESS=DEFLATE", "ZLEVEL=9", "NUMTHREADS=4"))
  
  ls = list("coefficients" = coeffs, "finalStack" = finalStack)
  return(ls)
}

get_harmonics()