library(tidyverse)
library(rgdal)
library(foreign)


# read in zip and city identification from census bureau geo crosswalk
xwalk <- read.csv("xwalk.csv", colClasses = c("bgrp" = "character", "trct" = "character"))

# extract city, zip fields
xwalk %<>%
  dplyr::select(GEOID = bgrp, city = stplcname, zip = zcta) %>%
  mutate(zip = as.factor(zip))


# read in housing+transpo data
## available at http://htaindex.cnt.org/download/data.php
htdata <- read.csv("htaindex_data_blkgrps_10580.csv", stringsAsFactors = FALSE)

htdata %<>% 
  mutate(GEOID = gsub("\"", "", blkgrp), pct.housing.transpo.typical.income.household = ht_ami*.01,
         pct.housing.typical.income = h_ami*.01, pct.transpo.typical.income.household = t_ami*.01,
         pct.transit.commuters.typical.income.household = pct_transit_commuters_ami*.01, pct.single.fam = frac_sfd*.01,
         pct.owner.occupied = pct_owner_occupied_hu*.01, pct.renter.occupied = pct_renter_occupied_hu*.01) %>%
  dplyr::select(GEOID, population, households, acreage = land_acres, pct.housing.transpo.typical.income.household, 
         pct.housing.typical.income, housing.cost = h_cost, pct.transpo.typical.income.household,
         household.co2 = co2_per_hh_local, autos.typical.income.household = autos_per_hh_ami, 
         typical.income.household.mileage = vmt_per_hh_ami, pct.transit.commuters.typical.income.household, 
         typical.income.household.transpo.cost = t_cost_ami, typical.income.household.auto.ownership.cost = 
         auto_ownership_cost_ami, typical.income.household.mileage.cost = vmt_cost_ami, 
         typical.income.household.transit.trips = transit_trips_ami, overall.employment.index = emp_ovrll_ndx, 
         employment.mix.index = emp_ndx, housing.units.per.acre = res_density, walkable.index = compact_ndx,
         gross.household.density = gross_hh_density, pct.transit.commuters.typical.income.household, 
         median.monthly.homeowner.cost = median_smoc, median.monthly.rent = median_gross_rent, pct.single.fam,
         pct.owner.occupied, pct.renter.occupied)


# read in EPA smart location data
## available at https://edg.epa.gov/data/PUBLIC/OP/SLD
smart <- read.dbf(file = "SLD_dbf.dbf", as.is = TRUE)

# filter to Albany core based statistical area
smart <- smart[smart$CBSA == 10580, ]

# select variables of interest
smart <- smart %>% 
  dplyr::select(GEOID = GEOID10, cbsa.total.employ = CBSA_EMP, cbsa.total.workers = CBSA_WRK, 
        pct.working.age = P_WRKAGE, zero.auto = AUTOOWN0, one.auto = AUTOOWN1, 
        two.plus.auto = AUTOOWN2P, num.workers.home = WORKERS, low.wage.workers.home = R_LOWWAGEW, 
        med.wage.workers.home = R_MEDWAGEW, hi.wage.workers.home = R_HIWAGEWK, 
        total.employ = EMPTOT, retail.jobs = E8_RET10, office.jobs = E8_OFF10, 
        industrial.jobs = E8_IND10, service.jobs = E8_SVC10, entertainment.jobs = E8_ENT10, 
        education.jobs = E8_ED10, healthcare.jobs = E8_HLTH10, public.admin.jobs = E8_PUB10, 
        job.type.mix = D2B_E8MIX, low.wage.workers.work = E_LOWWAGEW,
        med.wage.workers.work = E_MEDWAGEW, hi.wage.workers.work = E_HIWAGEWK,
        jobs.per.household = D2A_JPHH, pct.bg.employ.near.transit = D4b025,
        jobs.within.45.drive = D5ar, workers.within.45.drive = D5ae)

# join housing/transpo and smart location datasets for regression analysis
# remove observations with no housing cost 
all.data <- full_join(htdata, smart, by = "GEOID")
all.data <- all.data[!(is.na(all.data$housing.cost)), ]

## then go to regression.R for analysis and data export









