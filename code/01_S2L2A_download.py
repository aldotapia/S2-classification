#!/usr/bin/env python
"""
The following script aims to:
- Load a footprint of the study area
- Query the available products for the area based on these filters:
  - Start date: 2021-03-01
  - End date: 2022-06-01
  - Platform name: Sentinel-2
  - Relative orbit nuber: 96 (important for avoiding date with no data for this area)
  - Product type: S2MSI2A (Sentinel-2 Level 2A product)
- The query result is stored locally
- Finally, the products from the query are downloaded
Since I'm downloading to a local drive, but then unzipping in a different drive,
The script can run again and check the downloaded products and only download the missing ones
"""

import os

from sentinelsat import SentinelAPI, read_geojson, geojson_to_wkt
from datetime import date

USER = ''
PASSWORD = ''

# connect to the API
api = SentinelAPI(USER, PASSWORD, 'https://apihub.copernicus.eu/apihub')
footprint = geojson_to_wkt(read_geojson('../assets/studyarea.geojson'))

# query products with specific filters
products = api.query(footprint,
                     date=(date(2021, 3, 1), date(2022, 6, 1)),
                     platformname='Sentinel-2',
                     relativeorbitnumber=96,
                     producttype='S2MSI2A',
                     )

products_df = api.to_dataframe(products)
# products_df.to_csv('../assets/products_query.csv')

# download all the products
# api.download_all(products)

# check downloaded products and download the missing ones
products_path = 'path/to/Scenes'
scenes = [val.split('.')[0] for val in os.listdir(products_path)]
products_df = products_df[~products_df['title'].isin(scenes)]

# download the missing products
api.download_all(products_df.index)
