#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Jun 29 13:29:00 2017

@author: eline91
"""
import numpy as np
import src.convertToArray as ca
import src.utils.selectDates as sd
from scipy.optimize import curve_fit
import pandas as pd
import matplotlib.pyplot as plt
from time import time

inputDirectory = '/home/eline91/shared/userdata3/NDVI_imgs_int'
stacked, dateList, profile1image = ca.stack_images(inputDirectory, 1, \
                                                   "20140311", "20170311")

stacked2, dateList2, profile1image = ca.stack_images(inputDirectory, 2, \
                                                   "20140311", "20170311")

print stacked.shape
#print stacked

#for i in range(stacked.shape[1]):
#    for j in range(stacked.shape[2]):
#time = np.arange(1,stacked.shape[0]+1)
num_parameters = 5
resArray = np.empty((num_parameters, profile1image['height'], \
                     profile1image['width']))

def applyCurveFitPixel(t, r):
    
    def func(x, a, b, c, d, e):
        tau = 2 * np.pi
        return a*np.sin(x*tau) + b*np.cos(x*tau) + c*np.sin(2*x*tau) + \
                    d*np.cos(2*x*tau) + e
    
    coeffs, covs = curve_fit(func, t, r)
    return coeffs
    
def applyCurveFitLine(line, dateList):
    t0 = time()
    row = np.reshape(line, (len(stacked),stacked.shape[2]))
    resultList = []
    
    for i in range(line.shape[2]):
    for i in range()
        row = line[:,0,i]
        validData = np.where(row != -32768, True, False)
        t = np.array([ sd.toDecimalYears(x) for x in \
                     np.array(dateList)[validData] ])
        r = row[validData].astype(float)/10000
        if len(r) > 10:
            coeffs = list(applyCurveFitPixel(t, r))
        else:
            coeffs = [0,0,0,0,0]
        
        resultList.append(coeffs)
    print "The time is took to fit one line: " + str(time() - t0) + \
        "seconds."
    return resultList

results = applyCurveFitLine(stacked, dateList)
results2 = applyCurveFitLine(stacked2, dateList2)
complete = [results, results2]  
completeArray = np.array(complete)
completeArray =np.transpose(completeArray, axes=(2, 0, 1))
#def func(x, a, b, c, d, e):
#    tau = 2 * np.pi
#    return a*np.sin(x*tau) + b*np.cos(x*tau) + c*np.sin(2*x*tau) + \
#                    d*np.cos(2*x*tau) + e    
#
#row = stacked[:,0,6785]
#validData = np.where(row != -32768, True, False)
#dateList = np.array(dateList)[validData]
#t = np.array([ sd.toDecimalYears(x) for x in dateList ])
#r = row[validData].astype(float)/10000
#tau = 2 * np.pi
#d = {'a_time': t, 'b_ndvi': r, 'c_sin': np.sin(t*tau), 'd_cos': np.cos(t*tau),\
#     'e_sin2': np.sin(2*t*tau), 'f_cos2': np.cos(2*t*tau)}
#df = pd.DataFrame(data=d)

#labels = np.unique(trainData[trainData > 0]) 



#popt, pcov = curve_fit(func, t, r)
#
#plt.plot(t, r, 'b-', label='data')
#plt.plot(t, func(t, *popt), 'r-', label='fit')
#plt.show()

# param = np.apply_along_axis(np.mean, axis=0, arr=stacked )
# stacked[:,0,0]
