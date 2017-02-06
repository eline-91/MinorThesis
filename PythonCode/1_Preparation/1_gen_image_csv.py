# -*- coding: utf-8 -*-
"""
Eline van Elburg
06-02-2017

Script to generate a .csv list of images.
"""

import os
import glob
from datetime import datetime


def generate_image_list(image_directory, csv_name):
    sensor = "PROBAV"
    fpaths = os.path.join(image_directory, "*.tif")
    csv = open(csv_name, 'w')
    
    headers = "date,sensor,filename\n"
    csv.write(headers)
    
    for f in glob.glob(fpaths):
        fname = os.path.basename(f)
        raw_date =  fname[21:29]
        date_object = datetime.strptime(raw_date, '%Y%m%d').date()
        date = date_object.strftime('%Y%j')
        file_line = date + "," + sensor + "," + f + "\n"
        csv.write(file_line)

    csv.close()
    return None

if __name__ == "__main__":
    image_directory = "/home/eline91/shared/userdata3/cleanFiles_testArea"
    csv_name = os.path.join(image_directory, "image_list_testArea.csv")
    generate_image_list(image_directory, csv_name)