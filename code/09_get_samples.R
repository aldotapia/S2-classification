library(terra)
library(ggplot2)

mos = rast('/Volumes/TOSHIBA EXT/Msc/Mosaics_processed/ndvi.tif')
v = vect('/Volumes/TOSHIBA EXT/Msc/Vectors/samples.shp')
v = project(v, 'EPSG:32719')

sam = extract(mos, v)
sam$especie = v$especie

names(sam) = c('ID',
               paste0('ndvi_',month.abb),
               'ndvi_pen',
               'n',
               'specie')

write.csv(sam, '/Volumes/TOSHIBA EXT/Msc/Data/ndvi.csv')

mos = rast('/Volumes/TOSHIBA EXT/Msc/Mosaics_processed/B02.tif')
sam = extract(mos, v)
sam$especie = v$especie
names(sam) = c('ID',
               paste0('b02_',month.abb),
               'b02_pen',
               'n',
               'specie')
write.csv(sam, '/Volumes/TOSHIBA EXT/Msc/Data/B02.csv')

mos = rast('/Volumes/TOSHIBA EXT/Msc/Mosaics_processed/B03.tif')
sam = extract(mos, v)
sam$especie = v$especie
names(sam) = c('ID',
               paste0('b03_',month.abb),
               'b03_pen',
               'n',
               'specie')
write.csv(sam, '/Volumes/TOSHIBA EXT/Msc/Data/B03.csv')

mos = rast('/Volumes/TOSHIBA EXT/Msc/Mosaics_processed/B04.tif')
sam = extract(mos, v)
sam$especie = v$especie
names(sam) = c('ID',
               paste0('b04',month.abb),
               'b04_pen',
               'n',
               'specie')
write.csv(sam, '/Volumes/TOSHIBA EXT/Msc/Data/B04.csv')

mos = rast('/Volumes/TOSHIBA EXT/Msc/Mosaics_processed/B08.tif')
sam = extract(mos, v)
sam$especie = v$especie
names(sam) = c('ID',
               paste0('b08',month.abb),
               'b08_pen',
               'n',
               'specie')
write.csv(sam, '/Volumes/TOSHIBA EXT/Msc/Data/B08.csv')