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
zip.data <- read.csv("zip.data.csv", colClasses = c("GEOID" = "character", "zip" = "character"))
variables <- zip.data %>% gather(var, value, c(4:5, 7:10, 13)) %>% 
  select(-jobs.per.household, -jobs.within.45.drive)

# read in polygon data
blocks <- readOGR("blocks.shp", layer = "blocks", GDAL1_integer64_policy = TRUE) 

# choices for drop-downs
factors <- c(
  "Monthly housing cost" = "housing.cost",
  "Population" = "population",
  "Size of block group (acres)" = "acreage",
  "Annual household greehouse gas output from auto use (metric tons)" = "household.co2",
  "Percent of housing that is owner occupied" = "pct.owner.occupied",
  "Number of low-wage workers living in block group" = "low.wage.workers.home",
  "Number of high-wage workers living in block group" = "hi.wage.workers.home",
  "Jobs available with a 45-minute drive (weighted)" = "weighted.jobs.within.45.drive")
