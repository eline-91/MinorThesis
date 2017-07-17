library(probaV)
library(tools)
source("utils/SetTempPath.R")
source("getHarmonics.R")

# Perform function to obtain hamonics
inputDir <- "../../../userdata3/NDVI_images/"
outputDir <- "../../../userdata3/output/harmonics/"
ls <- get_harmonics(inputDir, outputDir, start_date = "2014-03-11", end_date = "2016-03-11")
 










# -------------------------------------------------------------------------------------------------------------- #
# Old code
# create output name on the metrics
OutputDir = "../../../userdata3/output/harmonics/"
OutputFile = paste0(OutputDir, "harmonic_coefficients_test.tif")
outputFilePA = paste0(OutputDir, "phase-amplitude_test.tif")
LogFile = paste0(OutputDir, "get_harmonics_test.log")
TileOfInterest = "X16Y06"
#TileOfInterest = "X20Y01"
CleanNDVIDir = "../../../userdata3/NDVI_images/"
#CleanNDVIDir = "/userdata2/master-classification/cleaned/ndvi/"
TempDir = "../../../userdata3/tmp/"

BandPattern = "NDVI_sm_ts.tif$"
#BandPattern = "NDVI_sm.tif$"
VrtFilename = paste0(TempDir, "harmonics.vrt")

# Create vrt of one image to define test extent
# Vrt_extent = timeVrtProbaV(CleanNDVIDir, pattern = BandPattern, vrt_name = VrtFilename, tile = TileOfInterest,
#                     start_date = "2014-03-11", end_date = "2014-03-11", return_raster = TRUE)
# ext <- extent(Vrt_extent, 6115, 6164, 8550, 8599)
# ext_testArea <- c(ext[1],ext[3],ext[2],ext[4])

# Create virtual stack
Vrt = timeVrtProbaV(CleanNDVIDir, pattern = BandPattern, vrt_name = VrtFilename, tile = TileOfInterest,
                    start_date = "2014-03-11", end_date = "2014-05-11", return_raster = TRUE) #,
                    #te = ext_testArea)

TS = timeVrtProbaV(CleanNDVIDir, pattern = BandPattern, vrt_name = VrtFilename, tile = TileOfInterest,
                   start_date = "2014-03-11", end_date = "2014-05-11", return_raster = FALSE) #,
                   #te = ext_testArea)

RowsPerThread = 14
Cores = 16

paste("layers:", nlayers(Vrt), "dates:", "blocks:", blockSize(Vrt, minrows = RowsPerThread)$n, "cores:", Cores)

if (!file.exists(OutputFile))
{
  psnice(value = min(Cores - 1, 19))
  system.time(Coeffs <- getHarmMetricsSpatial(Vrt, TS, minrows = RowsPerThread, mc.cores = Cores,
                                              logfile=LogFile, overwrite=TRUE, filename = OutputFile, 
                                              order = 2, datatype="FLT4S", progress="text"))
} else {
  print(paste(outputFile, "already exists.", sep=" "))
  Coeffs = brick(OutputFile) }

phaser = function(co, si)
{
  tau = 2*pi
  return(atan2(si, co) %% tau)
}
amplituder = function(co, si)
{
  return(sqrt(co^2 + si^2))
}

# Calculate phase and amplitude from our data
# Parameters, in order:
# min max intercept co si co2 si2 co3 si3 trend (blue, NDVI)
# min max intercept co si co2 si2 trend (blue, NDVI)
p1 = overlay(Coeffs[[4]], Coeffs[[5]], fun=phaser)
a1 = overlay(Coeffs[[4]], Coeffs[[5]], fun=amplituder)
p2 = overlay(Coeffs[[6]], Coeffs[[7]], fun=phaser)
a2 = overlay(Coeffs[[6]], Coeffs[[7]], fun=amplituder)

# Get mean NDVI value
# Could probably try to get it from trend and intercept, but rounding errors might be severe
MeanNDVI = mean(Vrt, na.rm=TRUE)

# Create final output
FinalStack = stack(MeanNDVI, p1, a1, p2, a2)
brick(FinalStack, filename=outputFilePA, datatype="FLT4S", overwrite=TRUE,
      progress="text", options=c("COMPRESS=DEFLATE", "ZLEVEL=9", "NUMTHREADS=4"))

# Try single raster
ras1 = raster("/home/eline91/shared/userdata3/NDVI_images/PROBAV_S5_TOC_X16Y06_20140311_100M_V101_NDVI_sm_ts.tif")
ras2 = raster("/home/eline91/shared/userdata3/NDVI_images/PROBAV_S5_TOC_X16Y06_20140316_100M_V101_NDVI_sm_ts.tif")
ras3 = raster("/home/eline91/shared/userdata3/NDVI_images/PROBAV_S5_TOC_X16Y06_20140321_100M_V101_NDVI_sm_ts.tif")
ras4 = raster("/home/eline91/shared/userdata3/NDVI_images/PROBAV_S5_TOC_X16Y06_20140326_100M_V101_NDVI_sm_ts.tif")
ras5 = raster("/home/eline91/shared/userdata3/NDVI_images/PROBAV_S5_TOC_X16Y06_20140401_100M_V101_NDVI_sm_ts.tif")
ras6 = raster("/home/eline91/shared/userdata3/NDVI_images/PROBAV_S5_TOC_X16Y06_20140406_100M_V101_NDVI_sm_ts.tif")
str(ras5)
str(ras6)
