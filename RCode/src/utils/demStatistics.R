# This function calculates slope, aspect and TPI of an input DEM, while 
# resampling it to a reference raster.
# This file should be sourced.

# Code largely based on code written by Dainius Masiliunas (edited):
# https://github.com/GreatEmerald/master-classification/blob/master/src/utils/dem-statistics.r

library(raster)

CalculateDEMStatistics = function(input, outdir, reference)
{
  SlopeFilename = paste0(outdir,"/slope.tif")
  TPIFilename = paste0(outdir,"/tpi.tif")
  PVHeightFilename = paste0(outdir,"/pv-height.tif")
  PVSlopeFilename = paste0(outdir,"/pv-slope.tif")
  PVHeightFilenameGRD = paste0(outdir,"/pv-height.grd")
  PVSlopeFilenameGRD = paste0(outdir,"/pv-slope.grd")
  PVTPIFilename = paste0(outdir,"/pv-tpi.tif")
  PVAspectFilename = paste0(outdir,"/pv-aspect.tif")
  totalRaster = paste0(outdir, "/pv_demVars.tif")
  
  # Calculate slope
  if (file.exists(SlopeFilename)) DEMSlope = raster(SlopeFilename)
  else DEMSlope = terrain(input, c("slope"), neighbors=4, datatype="FLT4S", filename=SlopeFilename)
  
  # Resample all to PROBA-V pixels
  if (file.exists(PVHeightFilename)) PVHeight = raster(PVHeightFilename)
  else {
    PVHeightgrd = raster::resample(input, reference, method="bilinear", datatype="INT2S", filename=PVHeightFilenameGRD)
    PVHeight = reclassify(PVHeightgrd, cbind(NA, 0), datatype="INT2S", filename = PVHeightFilename)
    }
  if (file.exists(PVSlopeFilename)) PVSlope = raster(PVSlopeFilename)
  else {
    PVSlopegrd = raster::resample(DEMSlope, reference, method="bilinear", datatype="FLT4S", filename=PVSlopeFilenameGRD)
    PVSlope = reclassify(PVSlopegrd, cbind(NA, 0), datatype="FLT4S", filename = PVSlopeFilename)
    }
  
  # Calculate aspect and TPI from the resampled data
  if (file.exists(PVAspectFilename)) PVAspect = raster(PVAspectFilename)
  else { PVAspect = terrain(PVHeight, c("aspect"), datatype="FLT4S", filename=PVAspectFilename)}
  if (file.exists(PVTPIFilename)) PVTPI = raster(PVTPIFilename)
  else { PVTPI = terrain(PVHeight, "tpi", datatype="FLT4S", filename=PVTPIFilename) }
  
  ml_ras = stack(PVHeight, PVSlope, PVAspect, PVTPI)
  writeRaster(ml_ras, filename = totalRaster, overwrite=TRUE)
}