source("utils/SetTempPath.R")
source("getHarmonics.R")

# Perform function to obtain hamonics
inputDir <- "../../../userdata3/NDVI_images/"
outputDir <- "../../../userdata3/output/harmonics/"
ls <- get_harmonics(inputDir, outputDir, start_date = "2014-03-11", end_date = "2016-03-11")