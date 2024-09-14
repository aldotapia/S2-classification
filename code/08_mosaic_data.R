library(terra)

# path to files
path = '/Volumes/TOSHIBA EXT/Msc/Splines/'
opath = '/Volumes/TOSHIBA EXT/Msc/Mosaics_processed/'

files = list.files(path, recursive = TRUE, pattern = '.tif$')

grids = substr(gsub('.*/',replacement = '', x = files),1,4)
grid = unique(grids)

bands = gsub('.tif', '', gsub('.*_',replacement = '', x = files))
band = unique(bands)

for(b in band){
  print(b)
  sel = bands %in% b
  files_sel = files[sel]
  jl = list()
  
  for(j in seq_along(files_sel)){
    jl[[j]] = rast(paste0(path, files_sel[j]))
  }
  
  m = list()
  
  for(i in 1:14){
    l = list()
    for(j in seq_along(files_sel)){
     l[[j]] = jl[[j]][[i]]
     
    }
    m[[i]] = mosaic(sprc(l))
  }
  
  r = rast(m)
  names(r) = paste0('lyr',sprintf("%02d", 1:14))
  
  writeRaster(r, paste0(opath, b, '.tif'))

  tmpFiles(remove = T)
}
