#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 12 10:59:06 2017

@author: eline91
"""
import gdal

def stack_images(inputDirectory, outputDirectory, stackName, regularExpression = "*")

outvrt = '/vsimem/stacked.vrt' #/vsimem is special in-memory virtual "directory"
outtif = '/tmp/stacked.tif'
tifs = ['a.tif', 'b.tif', 'c.tif', 'd.tif'] 
#or for all tifs in a dir
#import glob
#tifs = glob.glob('dir/*.tif')

outds = gdal.BuildVRT(outvrt, tifs, separate=True)
outds = gdal.Translate(outtif, outds)