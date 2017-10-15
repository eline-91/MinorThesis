#!/usr/bin/env Rscript

# This script preprocesses downloaded MODIS files, harmonizes the classes, and
# crops it to fit the PROBA-V data.

# R --slave --no-restore --file=preprocessMODIS.R

library(gdalUtils)
library(raster)
library(tools)
library(doParallel)
library(foreach)
source("utils/loadInfo.R")
source("utils/rasterUtils.R")

dataDir = info$folders$mod

# List all filepaths of the image folders
lf = list.files(dataDir)
lf = lf[nchar(lf) == 4]
imageList = character()

for (dir in lf)
{
  lsf = list.files(paste0(dataDir, dir), pattern = ".hdf$")
  imageList = c(imageList, paste0(dataDir, dir, "/", lsf))
}

# Loop through these datasets and write out the UMD (LC type 2) datasets (the
# second ones in every hdf file) as tiff files.
for (f in imageList) {
  sds = get_subdatasets(f)
  # Get correct dataset
  n = sds[grepl("Land_Cover_Type_2$", sds)]
  ras = raster(n)
  
  # Split name to make new filename
  sp = unlist(strsplit(n, ":"))
  filePath_original = sp[3]
  suffix = sp[5]
  
  new_path = paste0(file_path_sans_ext(filePath_original), "_", suffix, ".tif")
  
  if (!file.exists(new_path)) {
    print("Extracting...")
    writeRaster(ras, new_path)
  } else {
    print(paste0(new_path, " already exists."))
  }
}

# List all tiff files in each year folder, mosaic them, harmonize the classes
# and save the new files as well
for (dir in lf)
{
  # List all tiff files that need to be mosaiced
  rasters = list()
  lsf = paste0(dataDir, dir, "/", list.files(paste0(dataDir, dir), 
                                             pattern = "_Land_Cover_Type_2.tif$"))
  
  # Make rasters of these files, and put them in a list
  for (f in lsf) {
    rasters = list(rasters, raster(f))
  }
  rasters = unlist(rasters)
  
  # Define name for the mosaic and the harmonized mosaic
  mosaicName = paste0(dataDir, dir, "/mosaic_", dir, ".tif")
  harmonizedName = paste0(file_path_sans_ext(mosaicName), "_harmonized.tif")
  
  # Mosaic rasters if this hasn't been done yet
  if (!file.exists(mosaicName)) {
    print("Mosaicing...")
    modisMosaic = mosaic(rasters, fun=max, filename=mosaicName,
                      overwrite=TRUE, tolerance=0.5)
    
    print("Reclassifying...")
    mat = get_harmonizationMatrix()
    reclass = reclassify(x=modisMosaic, rcl=mat, filename=harmonizedName, 
                         datatype = "INT2S")
  } else {
    print(paste0(mosaicName, " already exists."))
    if (!file.exists(harmonizedName)) {
      print("Reclassifying...")
      modisMosaic = raster(mosaicName)
      mat = get_harmonizationMatrix()
      reclass = reclassify(x=modisMosaic, rcl=mat, filename=harmonizedName,
                           datatype = "INT2S")
    } else {
      print(paste0(harmonizedName, " already exists."))
    }
  }
}

# Crop the harmonized files to the study area, changing resolution in the 
# process. Gives an example of a PROBA-V image and resamples the MODIS image to 
# this extent and resolution.
PVExample = raster("/home/eline91/shared/userdata3/NDVI_images/PROBAV_S5_TOC_X16Y06_20140311_100M_V101_NDVI_sm_ts.tif")
cores = 5

# Start clusters for parallel processing
psnice(value = min(cores - 1, 19))
registerDoParallel(cores = cores)

# List images to process in parallel
mos_list = character()
for (dir in lf) {
  mos = paste0(dataDir, dir, "/", list.files(paste0(dataDir, dir), 
                                             pattern = "_harmonized.tif$"))
  mos_list = c(mos_list, mos)
}

foreach(i=1:length(mos_list), .packages = c("raster", "tools", "gdalUtils", "rgdal")) %dopar% {
  PVExample = raster("/home/eline91/shared/userdata3/NDVI_images/PROBAV_S5_TOC_X16Y06_20140311_100M_V101_NDVI_sm_ts.tif")

  croppedName = paste0(file_path_sans_ext(mos_list[i]), "PV.tif")
  
  if (!file.exists(croppedName)) {
    ras  <- raster(mos_list[i])
    
    print("Reprojecting...")
    input = projectRaster(ras, PVExample, method = "ngb", datatype = "INT2S",
                          filename = croppedName)
    
  } else {
    print(paste0(croppedName, " already exists."))
  }
}