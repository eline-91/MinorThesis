# -*- coding: utf-8 -*-
import os
import glob
import re
import time
from datetime import datetime as dt

def listDates(fileList):
    dateList = [re.search('([0-9]){8}', 
                          fname).group(0) for fname in fileList]
    return dateList

def selectDates(inputDirectory, startDate, endDate, 
                regularExpression):
    regEx = os.path.join(inputDirectory, regularExpression)
    totalList = glob.glob(regEx)
    fileList = totalList
    
    if startDate != None:
        dateList = listDates(totalList)
        startIndex = dateList.index(startDate)
        endIndex = dateList.index(endDate) + 1
        fileList = totalList[startIndex : endIndex]
        dateList = dateList[startIndex : endIndex]
    
    dateList = [ dt.strptime(x, '%Y%m%d') for x in dateList]
    
    return fileList, dateList

def toDecimalYears(date):
    # From stack overflow: https://stackoverflow.com/questions/6451655/
    #   python-how-to-convert-datetime-dates-to-decimal-years (edited)   
    def sinceEpoch(date): # returns seconds since epoch
        return time.mktime(date.timetuple())
    s = sinceEpoch
    year = date.year
    startOfThisYear = dt(year=year, month=1, day=1)
    startOfNextYear = dt(year=year+1, month=1, day=1)

    yearElapsed = s(date) - s(startOfThisYear)
    yearDuration = s(startOfNextYear) - s(startOfThisYear)
    fraction = round(yearElapsed/yearDuration, 5) +  0.0005 # Add small 
                                # fraction to make sure it's the right day

    return date.year + fraction

if __name__ == "__main__":
    inputDirectory = '/home/eline91/shared/userdata3/NDVI_images'
    print selectDates(inputDirectory, "20140311", "20140821", "*.tif")
    #selectDates(inputDirectory, None, None)
    
