#!/usr/bin/env Rscript

# Code based on code written by Dainius Masiliunas (edited):
# https://github.com/GreatEmerald/master-classification/blob/master/src/optical/get-harmonics.r

# The input is a folder with cleaned NDVI files (from configuration.yaml file). 
# The process cleans them again due to the nature of the PROBA-V package. 
# Output is two multi-band files with harmonic coefficients, one of which 
# contains the phases and amplitudes of the data.

# Most parameters are taken from the configuration.yaml file.

# Can be run via the command line, via for example:
# R --slave --no-restore --file=getHarmonics.R --args --version="2y" --order=2 --rowsPerThread=14 --cores=16

library(probaV)
library(tools)
library(optparse)
source("utils/SetTempPath.R")
source("utils/loadInfo.R")

# Command-line options
parser = OptionParser()
parser = add_option(parser, "--version", type="character", metavar="version",
                    default=NULL, help="Version to use, either the first two years ('2y'), or the third year ('3y').")
parser = add_option(parser, "--order", type="integer", metavar="integer",
                    default=2, help="Order of the regression. Choose 1, 2 or 3. (Default: %default)")
parser = add_option(parser, "--rowsPerThread", type="integer", metavar="integer",
                    default=14, help="Number of rows to process per thread. (Default: %default)")
parser = add_option(parser, "--cores", type="integer", metavar="integer",
                    default=16, help="Number of cores to use. (Default: %default)")
args = parse_args(parser)

get_harmonics = function(version=args[["version"]], order=args[["order"]],
                         rowsPerThread=args[["rowsPerThread"]],
                         cores=args[["cores"]], ...) {
  
  # Take necessary parameters and information from the configuration file
  inputDir = info$folders$NDVI_images
  bandPattern = info$dataset$bandPattern
  tile = info$dataset$tile
  tempDir = info$folders$temp
  
  # Depending on which version is chosen the rest of the parameters are set.
  if (version=="2y") {
    start_date = info$dataset$start_date
    end_date = info$dataset$end_date
    filePath_pa = info$classification$metrics_2y
    addon = ""
  } else if (version=="3y") {
    start_date = info$dataset$start_3y
    end_date = info$dataset$end_3y
    filePath_pa = info$classification$metrics_3y
    addon = "_3y"
  } else {
    print("Version unknown. Choose '2y' or '3y'.")
  }
  # Get output directory and direct the remaining output files to this same
  # directory
  outputDir = dirname(filePath_pa)
  filePath_harm = paste0(outputDir, "/harmonic_coefficients", addon, ".tif")
  filePath_log = paste0(outputDir, "/get_harmonics", addon, ".log")
  filePath_vrt = paste0(tempDir, "harmonics.vrt")
  
  print(paste0("The start date of the harmonics is: ", start_date, 
               ". The end of the harmonics is: ", end_date))
  
  # make virtual raster bricks based on the start and end dates
  vrt = timeVrtProbaV(inputDir, pattern = bandPattern, vrt_name = filePath_vrt, 
                      tile = tile, start_date = start_date, end_date = end_date, 
                      return_raster = TRUE, ...)
  
  ts = timeVrtProbaV(inputDir, pattern = bandPattern, vrt_name = filePath_vrt, 
                     tile = tile, start_date = start_date, end_date = end_date, 
                     return_raster = FALSE, ...)
  
  # Check if harmonic_coefficients.tif already exists in the output location
  if (!file.exists(filePath_harm)) {
    psnice(value = min(cores - 1, 19))
    system.time(coeffs <- getHarmMetricsSpatial(vrt, ts, minrows = rowsPerThread, 
                                                mc.cores = cores, logfile=filePath_log, 
                                                overwrite=TRUE, filename = filePath_harm, 
                                                order = order, datatype="FLT4S", 
                                                progress="text"))
    } else {
      print(paste(filePath_harm, "already exists.", sep=" "))
      coeffs = brick(filePath_harm)
    }
  
  # Helper functions to calculate the phases and amplitudes
  phaser = function(co, si)
  {
    tau = 2*pi
    return(atan2(si, co) %% tau)
  }
  
  amplituder = function(co, si)
  {
    return(sqrt(co^2 + si^2))
  }
  
  # Calculate the phases and amplitudes. The harmonic metrics output is ordered
  # in the following way: min max intercept co si co2 si2 trend
  p1 = overlay(coeffs[[4]], coeffs[[5]], fun=phaser)
  a1 = overlay(coeffs[[4]], coeffs[[5]], fun=amplituder)
  p2 = overlay(coeffs[[6]], coeffs[[7]], fun=phaser)
  a2 = overlay(coeffs[[6]], coeffs[[7]], fun=amplituder)
  
  # Calculate the mean of the NDVI data
  beginCluster(cores, nice = min(cores - 1, 19))
  meanData = clusterR(vrt, calc, args=list(mean, na.rm=TRUE))
  endCluster()
  
  # Form rasterbrick of the rasters mean, phase1, amplitude1, phase 2, amplitude2
  finalStack = stack(meanData, p1, a1, p2, a2)
  # Save this raster stack to file
  brick(finalStack, filename = filePath_pa, datatype = "FLT4S", overwrite = TRUE,
        progress = "text", options = c("COMPRESS=DEFLATE", "ZLEVEL=9", 
                                       "NUMTHREADS=4"))
  
}

get_harmonics()