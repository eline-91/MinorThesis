# Cleans the ProbaV data from clouds and cloud shadows and saves the cleaned files in another location
# To clean, it uses the mask provided with the data

library(probaV)
library(tools)
source("utils/SetTempPath.R")
source("utils/GetProbaVQCMask.R")

# Input and setting variables
dataDir <- "/data/MTDA/TIFFDERIVED/PROBAV_L3_S5_TOC_100M"
outputDir <- "../../../userdata3/cleanFiles"
QC.vals = GetProbaVQCMask(bluegood=TRUE, redgood=TRUE, nirgood=TRUE, swirgood=TRUE,
                          ice=FALSE, cloud=FALSE, shadow=FALSE)
psnice(value = 3)

# List all filepaths of the image folders
lf = list.files(dataDir)
lf = lf[nchar(lf) == 4]
imageDir = character()
totalDirs = character()
for (dir in lf)
  {
    lsf = list.files(paste0(dataDir, "/", dir))
    lsf = lsf[nchar(lsf) == 8]
    imageDir = c(imageDir, paste0(dir,'/',lsf))
  }
totalDirs = c(totalDirs, paste0(dataDir,'/',imageDir))
#testDirs = totalDirs[1:3]

# Processing all files for tile X16Y06
processProbaVbatch(totalDirs, tiles = "X16Y06", QC_val = QC.vals, overwrite=FALSE,
                   pattern = "NDVI.tif$", outdir = outputDir, ncores = 4)