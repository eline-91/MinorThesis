#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 12 09:31:41 2017

@author: eline91
"""

def classification():
    # Read worldfile of original dataset
    tfw_old = str(raster.split(".tif")[0]) + ".tfw"     

    # Read Data    
    img_ds = io.imread(raster)   
    img = np.array(img_ds, dtype='int16')    

    # call your random forest model
    rf = path_model + "model.pkl"          
    clf = joblib.load(rf)    

    # Classification of array and save as image (23 refers to the number of multitemporal NDVI bands in the stack) 
    new_shape = (img.shape[0] * img.shape[1], img.shape[2]) 
    img_as_array = img[:, :, :23].reshape(new_shape)   

    class_prediction = clf.predict(img_as_array) 
    class_prediction = class_prediction.reshape(img[:, :, 0].shape)  

    # now export your classificaiton
    classification = path_class  + "classification.tif" 
    io.imsave(classification, class_prediction)    

    # Assign Worldfile to classified image    
    tfw_new = classification.split(".tif")[0] + ".tfw"   
    shutil.copy(tfw_old, tfw_new)

classification()