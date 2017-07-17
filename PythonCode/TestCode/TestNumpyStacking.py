#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 14 13:44:00 2017

@author: eline91
"""

from time import time
import numpy as np

# Create 100 images of the same dimention 256x512 (8-bit). 
# In reality, each image comes from a different file
img = np.random.randint(0,255,(100, 256, 512))

# counter-intuitive but preallocation is slightly slower
stacked = np.empty((100, 256, 512))
t0 = time()
for n in range(100):
    stacked[n] = img[n]
print time()-t0  
print stacked.shape

array = np.zeros((1,10,3))
print array