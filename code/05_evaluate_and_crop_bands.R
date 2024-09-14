library(terra)

setwd('/Volumes/TOSHIBA EXT/Msc/')

bpath = 'Mosaics'
cpath = 'S2_Clouds_Merged'
opath = 'Gridded'
vpath = 'Vectors/grid_big_selection.shp'

bands = list.files(bpath, pattern = '.tif$')
clouds = list.files(cpath, pattern = '.tif$')
v = vect(vpath)

bnames = gsub(pattern = '_.*', replacement = '', bands)
cnames = gsub(pattern = '.tif*', replacement = '', clouds)
buniq = unique(bnames)

ids = v$gid

for(i in seq_along(buniq)){
  print(paste("Doing",buniq[i]))
  dir.create(file.path(opath, buniq[i]))
  bands_ = bands[bnames %in% buniq[i]]
  cloud_ = clouds[cnames %in% buniq[i]]
  
  rl = list()
  
  for(k in seq_along(bands_)){
    rl[[k]] = rast(file.path(bpath, bands_[k]))
  }
  
  if(length(cloud_) == 1){
    cloud_r = rast(file.path(cpath, cloud_))
    msk = terra::aggregate(cloud_r, fact = 15, fun='max')
    msk = focal(msk, w = 7, fun = 'max', na.rm=T)
    msk = msk>80
    msk = project(msk, rl[[1]], method = 'near')
    print('mask done')
  }
  
  for(j in ids){
    vtemp = v[v$gid == j,]
    msk_c = crop(msk, vtemp)
    test = global(msk_c, fun = 'mean', na.rm = T)
    
    for(k in seq_along(bands_)){
      if(length(cloud_) == 1){
        if(test < 0.1){
          temp = crop(rl[[k]], vtemp)
          #temp = mask(temp,msk_c, maskvalues = 1)
          writeRaster(temp,
                      filename = file.path(opath, buniq[i],
                                           paste0(sprintf("%04d", j),
                                                  '_',bands_[k])), overwrite = T)
          print(paste0('Done with ', bands_[k]))
        }else{
          print(paste0('Clouds detected for ', bands_[k]))
        }
        
      }else{
        temp = crop(rl[[k]], vtemp)
        writeRaster(temp,
                    filename = file.path(opath, buniq[i],
                                         paste0(sprintf("%04d", j),
                                                '_',bands_[k])), overwrite = T)
        print('no cloud layer detected')
      }
      
    }
  }
  
}

