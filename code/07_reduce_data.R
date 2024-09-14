library(terra)

# path to files
path = '/Volumes/TOSHIBA EXT/Msc/Gridded/'
opath = '/Volumes/TOSHIBA EXT/Msc/Splines/'

# main function definition
ndvi_spline_monthly <- function(x,times) {
  
  times <- times[!is.na(x)]
  
  x <- x[!is.na(x)]
  x[is.infinite(x)] = 0
  
  if(length(x) <= 4){
    vals <- rep(0, length.out = 12 + 1 + 1) # months plus score
  }else{
    sp <- smooth.spline(x = times,
                        y = x,
                        spar = 0.4)
    vals <- predict(sp, seq(from = 18748,
                            to = 19112,
                            by = 5))
    vals <- aggregate(vals$y,
                      list(format(as.Date(seq(from = 18748,
                                              to = 19112,
                                              by = 5),
                                          origin = "1970-01-01"),
                                  "%Y-%m")),
                      mean)[,'x']
    vals[vals > 1] = 1
    vals[vals < -1] = -1
    vals <- c(vals, sp$pen.crit, length(x))
  }
  vals
}

raster_spline_monthly <- function(x,times) {
  
  times <- times[!is.na(x)]
  
  x <- x[!is.na(x)]
  
  if(length(x) <= 4){
    vals <- rep(0, length.out = 12 + 1 + 1) # months plus score
  }else{
    sp <- smooth.spline(x = times,
                        y = x,
                        spar = 0.4)
    vals <- predict(sp, seq(from = 18748,
                            to = 19112,
                            by = 5))
    vals <- aggregate(vals$y,
                      list(format(as.Date(seq(from = 18748,
                                              to = 19112,
                                              by = 5),
                                          origin = "1970-01-01"),
                                  "%Y-%m")),
                      mean)[,'x']
    vals[vals > 1] = 1
    vals[vals < 0] = 0
    vals <- c(vals, sp$pen.crit, length(x))
  }
  vals
}

files = list.files(path, recursive = TRUE, pattern = '.tif$')

grids = substr(gsub('.*/',replacement = '', x = files),1,4)
grid = unique(grids)

donefiles = list.files(opath, recursive = TRUE, pattern = '.tif$')
gdone = unique(substr(donefiles, 1, 4))

#for(g in grid){
#  sel = grids %in% g
#  files_sel = files[sel]
#  dates = substr(gsub('.*/',replacement = '', x = files_sel),6,12)
#  dates = as.Date(dates, format = '%Y%j')
#  date = unique(dates)
#  print(paste0(g,': ',length(date)))
#  
#}

for(g in grid){
  if(g %in% gdone){
    print(paste0(g, ' done'))
  }else{
    print(g)
    sel = grids %in% g
    files_sel = files[sel]
    dates = substr(gsub('.*/',replacement = '', x = files_sel),6,13)
    dates = as.Date(dates, format = '%Y%m%d')
    date = unique(dates)
    
    ndvil = list()
    bluel = list()
    greenl = list()
    redl = list()
    nirl = list()
    
    ix = 1
    
    for(d in date){
      files_temp = files_sel[dates %in% d]
      bands = substr(gsub(pattern = '.*_', replacement = '', x = files_temp), 1, 3)
      if(length(bands) == 4){
        blue = rast(paste0(path, files_temp[bands == 'B02']))
        green = rast(paste0(path, files_temp[bands == 'B03']))
        red = rast(paste0(path, files_temp[bands == 'B04']))
        nir = rast(paste0(path, files_temp[bands == 'B08']))
        
        if(d >= '2022-01-25'){
          blue =  (blue-1000)/10000
          green = (green-1000)/10000
          red =   (red-1000)/10000
          nir =   (nir-1000)/10000
        }else{
          blue = blue/10000
          green = green/10000
          red = red/10000
          nir = nir/10000
        }
        
        names(blue) = as.character(d)
        names(green) = as.character(d)
        names(red) = as.character(d)
        names(nir) = as.character(d)
        ndvi = (nir-red)/(nir+red)
        
        names(ndvi) = as.character(d)
        
        bluel[[ix]] = blue
        greenl[[ix]] = green
        redl[[ix]] = red
        nirl[[ix]] = nir
        ndvil[[ix]] = ndvi
        ix = ix + 1
      }
    }
    
    ndvi = rast(ndvil)
    blue = rast(bluel)
    green = rast(greenl)
    red = rast(redl)
    nir = rast(nirl)
    
    result_ndvi <- app(ndvi,
                       ndvi_spline_monthly,
                       times = as.numeric(names(ndvi)),
                       cores = 15)
    
    result_blue <- app(blue,
                       raster_spline_monthly,
                       times = as.numeric(names(blue)),
                       cores = 15)
    
    result_green <- app(green,
                        raster_spline_monthly,
                        times = as.numeric(names(green)),
                        cores = 15)
    
    result_red <- app(red,
                      raster_spline_monthly,
                      times = as.numeric(names(red)),
                      cores = 15)
    
    result_nir <- app(nir,
                      raster_spline_monthly,
                      times = as.numeric(names(nir)),
                      cores = 15)
    
    writeRaster(x = result_ndvi,
                filename = paste0(opath,g,'_ndvi.tif'),
                gdal=c("COMPRESS=LZW"),
                overwrite = T)
    
    writeRaster(x = result_blue,
                filename = paste0(opath,g,'_B02.tif'),
                gdal=c("COMPRESS=LZW"),
                overwrite = T)
    
    writeRaster(x = result_green,
                filename = paste0(opath,g,'_B03.tif'),
                gdal=c("COMPRESS=LZW"),
                overwrite = T)
    
    writeRaster(x = result_red,
                filename = paste0(opath,g,'_B04.tif'),
                gdal=c("COMPRESS=LZW"),
                overwrite = T)
    
    writeRaster(x = result_nir,
                filename = paste0(opath,g,'_B08.tif'),
                gdal=c("COMPRESS=LZW"),
                overwrite = T)
    
    tmpFiles(remove = T)
  }
  
}
