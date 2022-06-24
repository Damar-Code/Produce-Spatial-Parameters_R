lapply(c("RSAGA", "terra", "usethis", "devtools","sp","raster","lattice","rgdal","gstat",
              "shapefiles","foreign"), require, character.only = TRUE)



# Setwd
setwd("...")

#library(devtools) #require to accses gitHUB Packages repository 
# Read Raster using "raster"
DEM <- raster("DEM.tif")
DEM <- projectRaster(DEM,
                     crs="+proj=utm +zone=49 +south +datum=WGS84 +units=m +no_defs")
DEM
plot(DEM)

# Setting RSAGA ENV
env <- rsaga.env(".../saga-6.3.0_x64")
rsaga.get.version(env)

# Produce Spatial Parameters
## Slope, Aspect, Plan Curvature, & Profile Curvature
rsaga.geoprocessor("ta_morphometry", 0, list( ELEVATION = "DEM.tif",
                                              SLOPE = "Slope.sgrd",
                                              ASPECT = "Aspect.sgrd",
                                              UNIT_SLOPE = 1,
                                              UNIT_ASPECT = 1,
                                              METHOD = 6), 
                   env = env)

## Slope in Radian
rsaga.geoprocessor("ta_morphometry", 0, list( ELEVATION = "DEM.tif",
                                              SLOPE = "Slope_radian.sgrd",
                                              UNIT_SLOPE = 0,
                                              METHOD = 6), 
                   env = env)

## Plan Curvature, Profile Curvature
rsaga.geoprocessor("ta_morphometry", 23, list( DEM = "DEM.tif",
                                               PLANC = "Plan Curvature.sgrd",
                                               PROFC = "Profile Curvature.sgrd"), 
                   env = env)


## Topographic Position Index
rsaga.geoprocessor("ta_morphometry", 18, list( DEM = "DEM.tif",
                                               TPI = "Topographic Position Index.sgrd",
                                               DW_WEIGHTING = 0),
                   env=env)

## Topographic Wetness Index
### Alexander Brenning (R interface), Juergen Boehner and Olaf Conrad (SAGA module) - (The Best: according to the wetness concentrations) 
rsaga.wetness.index(in.dem = "DEM.tif", out.wetness.index = "Topographic Wetness Index.sgrd", env=env)

## Stream Power Index
rsaga.geoprocessor("ta_hydrology", 21, list( AREA = "DEM.tif",
                                             SLOPE = "Slope_radian.sgrd",
                                             SPI = "Stream Power Index.sgrd",
                                             CONV = 0), 
                   env=env)
## Channel Network
rsaga.geoprocessor("ta_compound",0, list( ELEVATION = "DEM.tif",
                                          CHANNELS = "Channel Network.shp",
                                          CHNL_DIST = "Channel Distant.sgrd"),
                   env=env)

## Create DtD
### Step 1 - Read Channels File
DtD <- st_read("Channel Network.shp")
DtD <- st_zm(DtD)
DtD <- DtD[DtD$ORDER >= 2,]
st_write(DtD, "ORDER.shp")
### Step 2 - Rasterize the Channels
rsaga.geoprocessor("grid_gridding",0,list( INPUT = "ORDER.shp",
                                           FIELD = "ORDER",
                                           OUTPUT = 2,
                                           TARGET_USER_FITS = 1,
                                           TARGET_USER_SIZE = 1,
                                           GRID = "ORDER.sgrd"),
                   env=env)
### Step 3 - Proximity Grid
rsaga.geoprocessor("grid_tools",26,list( FEATURES = "ORDER.sgrd",
                                         DISTANCE = "DISTANCE.sgrd"),
                   env=env)
### Step 4 - Mask with Raster
rsaga.geoprocessor("grid_tools",24,list( GRID = "DISTANCE.sgrd",
                                         MASK = "DEM.tif",
                                         MASKED = "DtD.sgrd"),
                   env=env)
