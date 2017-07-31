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
zip.data <- read.csv("zip.data.csv", stringsAsFactors = FALSE, colClasses = c("GEOID" = "character", "zip" = "character"))

# read in polygon data
blocks <- readOGR("blocks.shp", layer = "blocks", GDAL1_integer64_policy = TRUE)

# choices for drop-downs
factors <- c(
  "Monthly housing cost" = "housing.cost",
  "Annual household greehouse gas output from auto use (metric tons)" = "household.co2",
  "Housing units per acre" = "housing.units.per.acre",
  "Percent of housing that is owner occupied" = "pct.owner.occupied",
  "Number of high-wage workers living in block group" = "hi.wage.workers.home",
  "Jobs available with a 45-minute drive" = "jobs.within.45.drive")
