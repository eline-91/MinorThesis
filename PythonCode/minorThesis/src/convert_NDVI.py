# -*- coding: utf-8 -*-
import os
import rasterio
import numpy as np
import src.utils.selectDates as sd
import src.convertToArray as ca

def convert_NDVI(imagePath, outputPath):
    #profile = None #Probably not necessary
    raster, profile, mask = ca.convert_to_np_array(imagePath)
        
    new_raster = np.zeros(raster.shape)
    new_raster = raster * 10000
    
    raster_nd = np.where(mask, -32768, new_raster)
    
    profile.update(dtype=rasterio.int16, nodata=-32768)
    
    with rasterio.open(outputPath, 'w', **profile) as dst:
        dst.write(raster_nd.astype(rasterio.int16))
        
def convert_NDVI_images(inputDirectory, outputDirectory, startDate = None, 
                        endDate = None, regularExpression = "*.tif"):
    
    tiffList = sd.selectDates(inputDirectory, startDate, endDate, 
                              regularExpression)[0]
    
    for f in tiffList:
        baseName = os.path.basename(f)
        fname, ext = os.path.splitext(baseName)
        outputName = os.path.join(outputDirectory, fname) + "_int" + ext
        
        convert_NDVI(f, outputName)
        
if __name__ == "__main__":
    imagePath = '/home/eline91/shared/userdata3/NDVI_images/PROBAV_S5_TOC_X16Y06_20140311_100M_V101_NDVI_sm_ts.tif'
    outputPath = '/home/eline91/shared/userdata3/testFiles/testConvertNDVI_20140311_ts_3.tif'
    convert_NDVI(imagePath, outputPath)
    
#    inputDirectory = '/home/eline91/shared/userdata3/NDVI_images'
#    outputDirectory = '/home/eline91/shared/userdata3/NDVI_imgs_int'
#    convert_NDVI_images(inputDirectory, outputDirectory, "20140311", "20140511")
    
    # TODO: add argparse code for running on command line
    
    
    