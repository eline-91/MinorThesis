# -*- coding: utf-8 -*-

import skimage.io as io
import numpy as np
import os, shutil
import src.convertToArray as ca
   
from sklearn.ensemble import AdaBoostClassifier, RandomForestClassifier, \
        GradientBoostingClassifier, ExtraTreesClassifier
from sklearn.externals import joblib
 
def train_time_series(inputDirectory, trainingPath, modelPath, 
                      classificationResultsPath, startDate, endDate):
    
    ts_stack = ca.stack_images(inputDirectory, startDate, endDate)
    trainData = ca.convert_to_np_array(trainingPath)[0]
    
    labels = np.unique(trainData[trainData > 0]) 
    print('The training data include {n} classes: {classes}' \
          .format(n=labels.size, classes=labels))
    
    
    
    pass




if __name__ == "__main__":
    inputDirectory = '/home/eline91/shared/userdata3/NDVI_imgs_int'
    trainingPath = '/home/eline91/shared/userdata3/TrainingData/' \
                'TotalTrainingDataPixels_080617.tif'
    modelPath = '/home/eline91/shared/userdata3/testFiles'
    classificationResultsPath = '/home/eline91/shared/userdata3/testFiles'
    startDate = "20140311"
    endDate = "20140316"
    
    train_time_series(inputDirectory, trainingPath, modelPath, 
                      classificationResultsPath, startDate, endDate)