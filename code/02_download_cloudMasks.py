#!/usr/bin/env python
"""
Once important step is detect clouds and either mask it out or discard scenes.
There are two main ways to do it, using the SCL scene (which comes with L2A products)
or using the cloud probability map (which comes with L1C products).
For this case, I'm using the output
"""

import ee
from geetools import batch

service_account = 'user@someone.gserviceaccount.com'
servacc_cred = '/path/to/key.json'
credentials = ee.ServiceAccountCredentials(service_account, servacc_cred)
ee.Initialize(credentials)

sentinel = ee.ImageCollection("COPERNICUS/S2_CLOUD_PROBABILITY")

# coordinates of the polygon to extract
limari = ee.Geometry.Polygon(
    [[[-71.7049, -30.2619],
      [-71.7049, -31.3236],
      [-70.2657, -31.3236],
      [-70.2657, -30.2619]]])

# date range
SrtDate = '2021-03-01'
EndDate = '2022-06-01'

collection = (sentinel
              .filterBounds(limari)
              .filterDate(SrtDate,EndDate))

exported_images = batch.Export.imagecollection.toDrive(
    collection=collection,
    folder='S2_Clouds',
    region=limari,
    scale=10,
    dataType='int',
    crs= 'EPSG:32719',
    maxPixels=10000000000000
)