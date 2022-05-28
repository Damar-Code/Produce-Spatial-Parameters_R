#########
lapply(c("RSAGA", "terra", "usethis", "devtools","sp","raster","lattice","rgdal","gstat",
              "shapefiles","foreign"), require, character.only = TRUE)



# Setwd
setwd("E:/APRIL/Skill Training/R/Automation/RSAGA")

#library(devtools) #require to accses gitHUB Packages repository 
# Read Raster using "raster"
DEM <- raster("DEM.tif")
DEM <- projectRaster(DEM,
                     crs="+proj=utm +zone=49 +south +datum=WGS84 +units=m +no_defs")
DEM
plot(DEM)

# Setting RSAGA ENV
env <- rsaga.env("C:/Program Files/saga-6.3.0_x64")
rsaga.get.version(env)

# write Tiff to .sgrd to perform raster in RSAGA
writeRaster(DEM, filename="DEM.sgrd", format="SAGA", overwrite=TRUE)

# List of Module in RSAGA
rsaga.get.modules(interactive = TRUE, env=env)
rsaga.get.usage("ta_hydrology",21, show = TRUE, env=env)

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
rsaga.wetness.index(in.dem = "DEM.tif", out.wetness.index = "Topographic Wetness Index_wetness-index.sgrd", env=env)

## Stream Power Index
rsaga.geoprocessor("ta_hydrology", 21, list( AREA = "DEM.tif",
                                             SLOPE = "Slope_radian.sgrd",
                                             SPI = "Stream Power Index.sgrd",
                                             CONV = 0), 
                   env=env)

## Landform
rsaga.geoprocessor("ta_morphometry", )


# Save all data into .gtif


to.tif <- function(pattern, pattern,destination_folder) {
  # Grab the file the location and format
  file_list <- list.files(path = origin_folder, pattern)
  file_list
  # Create Folder
  dir.create(paste0(destination_folder,"/GeoTIFF"))
  # Save to GeoTiff
  writeRaster(file_list, 'output.tif', overwrite=TRUE)
}


to.tif(origin_folder = "E:/APRIL/Skill Training/R/Automation/RSAGA",
       pattern = "sdat$", 
       destination_folder = "E:/APRIL/Skill Training/R/Automation/RSAGA")

origin_folder = "E:/APRIL/Skill Training/R/Automation/RSAGA"
pattern = "sdat$"
destination_folder = "E:/APRIL/Skill Training/R/Automation/RSAGA"

## Try
a <- raster("DEM.tif")
crs(a) <- "+proj=utm +zone=49 +south +datum=WGS84 +units=m +no_defs"
writeRaster(a, 'DEM2.tif', overwrite=TRUE)

b <- raster("DEM2.tif")
plot(b)


########################################---------------

lapply(c("rgdal","raster","rasterVis","lattice"),
       require, character.only = TRUE)


DEM <- raster("E:/Collage/GEOGRAFI UM/SM 7/Reseach Project/Pacet/QGIS/Final Landslide Conditioning Factors/Elevasi.tif")
DEM <- projectRaster(DEM,
                     crs="+proj=utm +zone=49 +south +datum=WGS84 +units=m +no_defs")
DEM

# Change 0 value to NA
values(DEM)[values(DEM) == 0] = NA

# Raster Visualization
rasterVis::levelplot(tr$slope,
                     margin = list(x = FALSE, 
                                   y = TRUE),
                     col.regions = terrain.colors(16),
                     xlab = list(label = "", 
                                 vjust = -0.25),
                     sub = list(
                       label = "masl",
                       font = 1,
                       cex = .9,
                       hjust = 1.5))

# Generate Spatial Parameter
SLOPE <- terrain(DEM, opt = 'slope', unit = 'degrees')
ASPECT <- terrain(DEM, opt = 'aspect', unit = 'degrees')
tr <- terrain(DEM, opt = c("aspect","slope"), unit= 'degrees', neighbors = 4)

# Reclassify Raster
## 1. change to data frame
df = as.data.frame(tr, xy =T)
df <- df[complete.cases(df), ]

## 2. View the data
library(ggplot2)

ggplot()+
  geom_tile(df, mapping=aes(x = x, y = y, fill = slope))+
  scale_fill_gradientn(colors = terrain.colors(20), na.value="transparent")+
  theme_bw()

## 3. Reclassify
library(dplyr)

df <- df %>% 
  mutate(SLOPE_CLS= case_when(slope <= 2 ~ "1",
                              slope >2 & slope < 4 ~ "2",
                              slope >= 4 & slope < 8 ~ "3",
                              slope >= 8 & slope < 16 ~ "4",
                              slope >= 4 & slope < 35 ~ "5",
                              slope >= 4 & slope < 55 ~ "6",
                              slope >= 55 ~ "7"))
df <- df %>% 
  mutate(ASPECT_CLS= case_when(aspect == 0 ~ "1",
                              aspect >0 & aspect < 22.5 ~ "2",
                              aspect >= 22.5 & aspect < 67.5 ~ "3",
                              aspect >= 67.5 & aspect < 112.5 ~ "4",
                              aspect >= 112.5 & aspect < 157.5 ~ "5",
                              aspect >= 157.5 & aspect < 202.5 ~ "6",
                              aspect >= 202.5 & aspect < 247.5 ~ "7",
                              aspect >= 247.5 & aspect < 292.5 ~ "8",
                              aspect >= 292.5 & aspect < 337.5 ~ "9",
                              aspect >= 337.5 & aspect ~ "2"))

df

## ggplot2 visualization
slopeVanZuidam <- c("#157917", "#66a80f", "#84e200", "#fef702","#f5ad0a","#ec6313","#e31a1c")
aspect9 <- c("#989198","#5dff00","#0b9200","#005abb","#80007a","#e5007b","#fa4d00","#fa991f",
             "#efe700","#5dff00")

Slope <- ggplot()+
  geom_tile(df, mapping=aes(x = x, y = y, fill = SLOPE_CLS))+
  scale_fill_manual(values = slopeVanZuidam)+
  theme_bw()
Aspect <- ggplot()+
  geom_tile(df, mapping=aes(x = x, y = y, fill = ASPECT_CLS))+
  scale_fill_manual(values = aspect9)+
  theme_bw()


library(ggpubr)
ggarrange(
  Slope, Aspect, labels = c("A", "B"),
  common.legend = TRUE, legend = "bottom"
)

