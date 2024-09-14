library(terra)

setwd('/Volumes/TOSHIBA EXT/Msc/')

ipath = 'Gridded'
opath = 'ndvi'

files = list.files(ipath, recursive = TRUE)
filesfull = list.files(ipath, recursive = TRUE, full.names = TRUE)

dates = gsub(pattern = '/.*', replacement = '', x = files)
dates = as.Date(dates, format = '%Y%m%d')
datesu = unique(dates)

ids = substr(gsub(pattern = '.*/', replacement = '', x = files),1,4)
idsu = unique(ids)

for (i in 1:length(idsu)) {
  dir.create(file.path(opath, idsu[i]))
  for (j in 1:length(datesu)) {
    tempfiles = filesfull[dates %in% datesu[j] & ids %in% idsu[i]]
    
    if (length(tempfiles) == 4) {
      B04 = tempfiles[grep(pattern = 'B04', x = tempfiles)]
      B08 = tempfiles[grep(pattern = 'B08', x = tempfiles)]
      red = rast(B04)
      nir = rast(B08)
      
      ndvi = (nir - red) / (nir + red)
      
      writeRaster(ndvi, filename = paste0(opath, '/', idsu[i], '/', datesu[j], '.tif'), overwrite = TRUE)
      print(paste0('Done ', idsu[i], ' ', datesu[j]))
    }else{
      print(paste0('Missing ', idsu[i], ' ', datesu[j]))
    }
    
  }
}
