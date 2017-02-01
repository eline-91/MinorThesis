# Clean images using the time series method

library(probaV)
library(tools)
library(dplyr)
source("utils/SetTempPath.R")
source("../../probaVcode/cloud_filter.R") # JD's extra utility script

# Input and Setting variables
#setwd("/home/eline91/shared/Code/RCode/src")

inputDir <- "../../../userdata3/cleanFiles"
outputDir <- "../../../userdata3/cloudFiltered"
stackDir <- "../../../userdata3/virStack"

# Tiles of interest
tile <- c("X16Y06")
#tile <- c("X17Y06")

### ----- 1. Create virtual stack and crop the tiles to the extent of the study area ----- ###
# Directory with cleaned fles (using the probaV pixel mask)
ProbaV_sm_dir <- paste(inputDir,"/", sep = "")
df_ProbaV_sm <- getProbaVinfo(ProbaV_sm_dir, pattern ='_sm.tif$', tiles = tile)
glimpse(df_ProbaV_sm) # Visualizing some infrmation

# Setting the extents of the study area of both tiles (xmin, ymin, xmax, ymax)
ext_X16Y06 <- c(-14.135417,5.000496,-10.000496,15.000496)
ext_X17Y06 <- c(-10.000496,5.000496,-8.284226,15.000496)

## Small extent used for testing
ext_Testing <- c(-12.074901,9.008433,-12.024306,9.059028)

# Assign parameters
bands <-  df_ProbaV_sm[df_ProbaV_sm$date == df_ProbaV_sm$date[1], 'band']
dates <-  df_ProbaV_sm[df_ProbaV_sm$band == bands[1], 'date']
minrows = 10
mc.cores = 5

# Assign logfile name 
logfile <- file.path(paste0("../../userdata3/logFiles", tile, ".log"))

# Band selection and adding '_sm.tif' extension
bands_select <- '(BLUE|RED0|NIR0|SWIR)'
bands_sm <- paste(bands_select,'_sm.tif$', sep = "")

# Make vrt 
vrt_name <- file.path(stackDir, paste0(tile, "_",paste0(bands, collapse = "_"), ".vrt"))

# !! Change extent to different tile when necessary !!
b_vrt <- timeVrtProbaV(ProbaV_sm_dir, pattern = bands_sm, vrt_name = vrt_name, tile = tile[1], 
                       return_raster = T, start_date = "2014-03-11", end_date = "2015-01-16", 
                       te = ext_Testing)
df_b_vrt <- timeVrtProbaV(ProbaV_sm_dir, pattern = bands_sm, vrt_name = vrt_name, tile = tile[1], 
                          return_raster = F, start_date = "2014-03-11", end_date = "2015-01-16", 
                          te = ext_Testing)
#b_vrt <- timeVrtProbaV(ProbaV_sm_dir, pattern = bands_sm, vrt_name = vrt_name, tile = tile[1], 
#                       return_raster = T, te = ext_X16Y06)
#df_b_vrt <- timeVrtProbaV(ProbaV_sm_dir, pattern = bands_sm, vrt_name = vrt_name, tile = tile[1], 
#                          return_raster = F, te = ext_X16Y06)



### ----- 2. Perform cloud filter ----- ###
outputName <- file.path(outputDir, "cloud_filter.envi")

cloud_filter(x = b_vrt, probav_sm_dir = ProbaV_sm_dir, cf_bands = c(1,4), pattern = bands_sm, tiles = tile[1], 
             thresholds = c(-80, Inf), span = 0.3, minrows = minrows, mc.cores = mc.cores, logfile = logfile, 
             overwrite = T, filename = outputName)

### -------- Define extent based on row- and columnnumbers --------- ###
options(digits=15)
b_vrt <- timeVrtProbaV(ProbaV_sm_dir, pattern = bands_sm, vrt_name = vrt_name, tile = tile[1], 
                       return_raster = T, start_date = "2014-03-11", end_date = "2014-03-11")
#plot(b_vrt)
ext <- extent(b_vrt, 1, 9080, 6880, 10080)
ext
ext_studyArea <- c(ext[1],ext[3],ext[2],ext[4])

c_vrt <- timeVrtProbaV(ProbaV_sm_dir, pattern = bands_sm, vrt_name = vrt_name, tile = tile[1], 
                        return_raster = T, start_date = "2014-03-11", end_date = "2014-03-11", 
                        te = ext_studyArea)
#plot(c_vrt)

# --------- smaller test extent
b_vrt <- timeVrtProbaV(ProbaV_sm_dir, pattern = bands_sm, vrt_name = vrt_name, tile = tile[1], 
                       return_raster = T, start_date = "2014-03-11", end_date = "2014-03-11")
#plot(b_vrt)
ext2 <- extent(b_vrt, 5000, 7079, 8881, 10080)
ext2
ext_testArea <- c(ext2[1],ext2[3],ext2[2],ext2[4])

c_vrt <- timeVrtProbaV(ProbaV_sm_dir, pattern = bands_sm, vrt_name = vrt_name, tile = tile[1], 
                       return_raster = T, start_date = "2014-03-11", end_date = "2014-03-11", 
                       te = ext_testArea)
#plot(c_vrt)
dim(c_vrt)
