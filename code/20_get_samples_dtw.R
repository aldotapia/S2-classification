library(terra)
library(dplyr)
library(tidyr)

setwd('/Volumes/TOSHIBA EXT/Msc/')

# path to files
path = '/Volumes/TOSHIBA EXT/Msc/Gridded'

v = vect('/Volumes/TOSHIBA EXT/Msc/Vectors/samples_grid.shp')
# project to EPSG:32719
v = project(v, 'EPSG:32719')
v$id = 1:nrow(v)

# list files
files = list.files(path, pattern = '.tif$', recursive = TRUE, full.names = TRUE)

ids = gsub(pattern = '.*/', replacement = '', files)
ids = as.numeric(substr(ids, 1, 4))
ids_u = sort(unique(ids))

ids_v = sort(unique(v$gid))

bands = gsub(pattern = '.*_B', replacement = '', files)
bands = as.numeric(substr(bands, 1, 2))
bands_u = unique(bands)

# create empty list
l = list()

# loop through files
for(i in seq_along(ids_v)){
  
  v_temp = v[v$gid == ids_v[i],]
  
  for(j in seq_along(bands_u)){
    files_temp = files[ids == ids_v[i] & bands == bands_u[j]]
    
    r = rast(files_temp)
    
    ex = terra::extract(r, v_temp)
    
    ex$ID = v_temp$id
    ex$especie = v_temp$especie
    
    ex %>% pivot_longer(cols = -c(ID, especie)) %>%
      mutate(band = gsub(pattern='.*_',replacement='', name),
             date = gsub(pattern='_.*',replacement='', name)) %>%
      select(-name) -> ex
    
    l[[paste0('id_', ids_v[i], '_band_', bands_u[j])]] = ex
  }
  
  print(paste0('id_', ids_v[i],' done'))
}

do.call(rbind, l) -> df

write.csv(df, '/Users/aldotapia/Documents/GitHub/S2-classification/Data/for_dtw.csv', row.names = FALSE)
