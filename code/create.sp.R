library(tidyverse)
library(sp)
library(rgdal)

### create spatial polygon data frames for leaflet polygons
# read in polygon data
blockgrps <- readOGR("cb_2013_36_bg_500k.shp", layer = "cb_2013_36_bg_500k", GDAL1_integer64_policy = TRUE)

# create dataset to join to polygon
blocks <- all.data %<>%
  distinct(GEOID, .keep_all = TRUE) %>%
  gather(factors, values, 2:9)

# subset GIS data to exclude block groups not in housing dataset
block.ids <- blocks$GEOID
blockgrps <- blockgrps[blockgrps@data$GEOID %in% block.ids, ]

# merge data frames
spdf.blocks <- sp::merge(blockgrps, blocks, duplicateGeoms = TRUE)

# write spatial object
writeOGR(obj = spdf.blocks, dsn = "alb.housing.costs", layer = "blocks", driver="ESRI Shapefile")


### create spatial polygon data frames for leaflet polygons
# read in polygon data
blockgrps <- readOGR("cb_2013_36_bg_500k.shp", layer = "cb_2013_36_bg_500k", GDAL1_integer64_policy = TRUE) 

# create dataset to join to polygon
blocks <- all.data %<>%
  distinct(id, .keep_all = TRUE) %>%
  gather(factors, values, c(2:8, 11))

# subset GIS data to exclude block groups not in housing dataset
block.ids <- blocks$GEOID
blockgrps <- blockgrps[blockgrps@data$GEOID %in% block.ids, ]

# merge data frames
spdf.blocks <- sp::merge(blockgrps, blocks, duplicateGeoms = TRUE)

# write spatial object
writeOGR(obj = spdf.blocks, dsn = "alb.housing.costs", layer = "blocks", driver="ESRI Shapefile")
