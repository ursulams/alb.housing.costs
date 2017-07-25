library(tidyverse)
library(shiny)
library(shinythemes)
library(leaflet)
library(viridis)
library(DT)
library(sp)
library(rgdal)
library(htmltools)
library(ggthemes)


# read in table data
zip.data <- read.csv("zip.data.csv", colClasses = c("GEOID" = "character", zip = "character"))

### create spatial polygon data frames for leaflet polygons
# read in polygon data
blocks <- readOGR("blocks.shp", layer = "blocks", GDAL1_integer64_policy = TRUE) 

# choices for drop-downs
factors <- c(
  "Monthly housing cost" = "housing.cost",
  "Size of block group (acres)" = "acreage",
  "Annual household greehouse gas output from auto use (metric tons)" = "household.co2",
  "Percent of housing that is owner occupied" = "pct.owner.occupied",
  "Number of high-wage workers living in block group" = "hi.wage.workers.home",
  "Jobs available with a 45-minute drive" = "jobs.within.45.drive")
