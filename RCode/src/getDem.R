# This script serves to download and preprocess GLSDEM elevation data from the
# following url: ftp://ftp.glcf.umd.edu/glcf/GLSDEM/Degree_tiles

# Code largely based on code written by Dainius Masiliunas (edited):
# https://github.com/GreatEmerald/master-classification/blob/master/src/elevation/get-dem.r

library(R.utils)
library(landsat)
library(raster)
source("utils/rasterUtils.R")
source("utils/demStatistics.R")

# Set directory and specify tiles covering the study area
GLSDir = "../../../userdata3/glsdem"
TilesN = c("04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15")
TilesW = c("09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20")

dems = list()
for(n in TilesN)
{
  for(w in TilesW)
  {
    filename = paste0("GLSDEM_n0", n, "w0", w, ".tif")
    url = paste0("ftp://ftp.glcf.umd.edu/glcf/GLSDEM/Degree_tiles/n0", n,
                 "/GLSDEM_n0", n, "w0", w, "/", filename, ".gz")
    outfile = paste0(GLSDir, "/", filename)
    outfilegz = paste0(outfile, ".gz")
    if(!file.exists(outfilegz) && !file.exists(outfile))
      download.file(url, outfilegz, "wget")
    if(file.exists(outfilegz) && file.size(outfilegz) > 0)
      gunzip(paste0(outfile, ".gz"))
    if(file.exists(outfile) && file.size(outfile) > 0)
      dems = list(dems, raster(outfile))
  }
}
dems = unlist(dems)

# Mosaic the separate DEMs together
GLSMosaic = mosaic(dems, fun=mean, filename=paste0(GLSDir, "/mosaic.grd"), 
                   overwrite=TRUE, tolerance=0.5)

# There are no rasters available for the ocean part of the study area, so this
# is filled in separately.
GLSMosaic = reclassify(GLSMosaic, cbind(NA, 0))
writeRaster(GLSMosaic, filename=paste0(GLSDir,"/mosaic.tif"), overwrite=TRUE)

# Gives an example of a PROBA-V image and resamples the DEM mosaic to this extent
# and resolution, as well as calculating DEM derivatives.
PVExample = raster("/home/eline91/shared/userdata3/NDVI_images/PROBAV_S5_TOC_X16Y06_20160711_100M_V101_NDVI_sm_ts.tif")
CalculateDEMStatistics(GLSMosaic, GLSDir, PVExample)