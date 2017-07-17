#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 12 10:59:06 2017

@author: eline91
"""

import rasterio
import numpy as np
from time import time
import src.utils.selectDates as sd

def convert_to_np_array(filePath, row = None):
    with rasterio.open(filePath) as ras:
        raster = ras.read(window=((row-1, row), (None, None)), masked = True)
        profile = ras.profile
        mask = raster.mask
    return raster, profile, mask
    

def stack_images(inputDirectory, row = None, startDate = None, endDate = None, 
                 regularExpression = "*.tif"):
    print "Start stacking...."
    tiffList, dateList = sd.selectDates(inputDirectory, startDate, endDate, 
                              regularExpression)
    rast, profile1image , mask1image = convert_to_np_array(tiffList[0], row)
    height = rast.shape[1]
    width = rast.shape[2]
    dtype = rast.dtype
    
    t0 = time()
    stacked = np.empty((len(tiffList), height, width), dtype = dtype)
    for n in range(len(tiffList)):
        raster = convert_to_np_array(tiffList[n], row)[0]
        stacked[n] = raster
    print "The time is took to stack " + str(len(tiffList)) + \
        " images is: " + str(time() - t0)
    print "The shape of the stacked array is: " + str(stacked.shape)
    print "The data type of the array is: " + str(stacked.dtype)
    print "The data type of one image is: " + str(stacked[0].dtype)
    
    return stacked, dateList, profile1image
    
if __name__ == "__main__":
    inputDirectory = '/home/eline91/shared/userdata3/NDVI_imgs_int'
    stacked = stack_images(inputDirectory, 1, "20140311", "20140411")
    
    filePath = '/home/eline91/shared/userdata3/TrainingData/' \
                    'TotalTrainingDataPixels_080617.tif'
    rasterTrain, profile, mask = convert_to_np_array(filePath, None)
    print rasterTrain.dtype
    
    filePath = '/home/eline91/shared/userdata3/NDVI_imgs_int/' \
                'PROBAV_S5_TOC_X16Y06_20140311_100M_V101_NDVI_sm_ts_int.tif'
    raster, profile, mask = convert_to_np_array(filePath, 1)
    print raster.dtype
    
    