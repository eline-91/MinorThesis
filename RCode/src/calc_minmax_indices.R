#!/usr/bin/env Rscript

# The input is a folder with cleaned NDVI files (from configuration.yaml file). 
# This script calculates a minimum and maximum NDVI value for each pixel, by 
# extracting the 25% lowest and highest values, and then taking the median.
# The output is a two-band tiff file containing the minumum and maximum.

# Most parameters are taken from the configuration.yaml file:
# - NDVI input directory
# - band pattern and tile information
# - temporary directory
# - start and end date of the first two years as well as the second year (it
#   depends on the version chosen which start and end dates are used)
# - Filepath of the output raster

# Can be run via the command line, via for example:
# R --slave --no-restore --file=calc_minmax_indices.R --args --version="2y" --cores=16

library(probaV)
library(tools)
library(optparse)
source("utils/SetTempPath.R")
source("utils/loadInfo.R")
library(snow)

# Command-line options
parser = OptionParser()
parser = add_option(parser, "--version", type="character", metavar="version",
                    default=NULL, help="Version to use, either the first two years ('2y'), or the third year ('3y').")
parser = add_option(parser, "--cores", type="integer", metavar="integer",
                    default=16, help="Number of cores to use. (Default: %default)")
args = parse_args(parser)

get_minmax = function(version=args[["version"]],
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
    filePath_minmax = info$classification$minmax_2y
  } else if (version=="3y") {
    start_date = info$dataset$start_3y
    end_date = info$dataset$end_3y
    filePath_minmax = info$classification$minmax_3y
  } else {
    print("Version unknown. Choose '2y' or '3y'.")
  }
  
  # Filename of temporary vrt file
  filePath_vrt = paste0(tempDir, "minmax.vrt")
  filePath_ts = paste0(tempDir, "minmax_ts.vrt")
  
  print(paste0("The start date of the harmonics is: ", start_date, 
               ". The end of the harmonics is: ", end_date))
  
  # make virtual raster brick based on the start and end dates
  vrt = timeVrtProbaV(inputDir, pattern = bandPattern, vrt_name = filePath_vrt, 
                      tile = tile, start_date = start_date, end_date = end_date, 
                      return_raster = TRUE)
  
  ts = timeVrtProbaV(inputDir, pattern = bandPattern, vrt_name = filePath_ts, 
                     tile = tile, start_date = start_date, end_date = end_date, 
                     return_raster = FALSE)
  
  # Check if min_max.tif already exists in the output location
  if (!file.exists(filePath_minmax)) {
    psnice(value = min(cores - 1, 19))
    
    # Helper function to find median minimum value
    minimizer = function(x) {
      x <- x[!is.na(x)]
      y = sort(x)[1:(length(x)/4)]
      med = median(y)
      return(med)
    }
    
    # Helper function to find median maximum value
    maximizer = function(x) {
      x <- x[!is.na(x)]
      y = sort(x, decreasing=TRUE)[1:(length(x)/4)]
      med = median(y)
      return(med)
    }
    
    # Allow to process this on multiple cores
    beginCluster(cores, nice = min(cores - 1, 19))
    median.minimum = clusterR(vrt, calc, args=list(fun=minimizer))
    endCluster()
    
    # Allow to process this on multiple cores
    beginCluster(cores, nice = min(cores - 1, 19))
    median.maximum = clusterR(vrt, calc, args=list(fun=maximizer))
    endCluster()
    
    # Create stack containing both the minimum and the maximum value
    medians = stack(median.minimum, median.maximum)
    
    # Save this raster stack to file
    brick(medians, filename = filePath_minmax, datatype = "FLT4S", 
          overwrite = TRUE, progress = "text", 
          options = c("COMPRESS=DEFLATE", "ZLEVEL=9", "NUMTHREADS=4"))
    
  } else {
    print(paste(filePath_minmax, "already exists.", sep=" "))
  }
}

get_minmax()