# script to run multiple regression analysis to find factors most influencing housing costs

library(car)
library(leaps)
library(corrgram)
library(dplyr)
library(MASS)

all.data <- read.csv("all.data.csv", stringsAsFactors = FALSE)

# model selection through best subsets exhaustive search to find variables with highest r^2
attach(all.data)

leaps <- regsubsets(housing.cost~
                      population +
                      households +
                      acreage +
                      gross.household.density +
                      autos.typical.income.household +
                      household.co2 +
                      jobs.per.household +
                      overall.employment.index +
                      housing.units.per.acre +
                      employment.mix.index +
                      job.type.mix +
                      walkable.index +
                      pct.single.fam +
                      pct.owner.occupied +
                      low.wage.workers.home +
                      med.wage.workers.home +
                      hi.wage.workers.home +
                      pct.working.age +
                      total.employ +
                      office.jobs +
                      service.jobs +
                      job.type.mix +
                      jobs.within.45.drive, data = all.data, method = "exhaustive", nbest = 20)

# view results
summary(leaps)

# plot a table of models showing variables in each model.
# models are ordered by the selection statistic.
par(mfrow=c(1,2))
plot(leaps, scale="r2")
plot(leaps, scale="adjr2")

# regress housing cost against most promising variables
fit <- lm(housing.cost~
            population +
            acreage +
            household.co2 +
            walkable.index +
            pct.owner.occupied +
            med.wage.workers.home +
            hi.wage.workers.home +
            jobs.within.45.drive)

summary(fit)

# test for  multicollinearity
# first: Pearson's correlation coefficient
# med wage variable has high coefficients to two other variables
cor(all.data[c("housing.cost", "population", "acreage", "household.co2", "walkable.index", "pct.owner.occupied",
          "med.wage.workers.home", "hi.wage.workers.home", "jobs.within.45.drive")], use = "complete")

corrgram(all.data[, c("housing.cost", "population", "acreage", "household.co2", "walkable.index", "pct.owner.occupied",
                    "med.wage.workers.home", "hi.wage.workers.home", "jobs.within.45.drive")],
         lower.panel=panel.shade, upper.panel=panel.conf)

# second: variance inflation factors
# no problematic variable (>10), wakable index borderline (9.5)
vif(fit)

# model's diagnostic plots
# QQ plot indicates nonnormal distribution of residuals (right skew)
par(mfrow = c(2, 2))
plot(fit)
crPlots(fit)

# plot variables' distribution
scatterplotMatrix(~ housing.cost +
                    population +
                    acreage +
                    household.co2 +
                    walkable.index +
                    pct.owner.occupied +
                    med.wage.workers.home +
                    hi.wage.workers.home +
                    jobs.within.45.drive,
                  data = all.data, main = "regression variables")

# transform housing cost variable to address fat tail residual distribution
# acreage, med wage, and jobs variables flipped signs
## replace acreage with housing units per acre factor
## remove population and med.wage variables because of high coefficients
## weight jobs within 45 drive with factor of jobs per household in block group


fit2 <- lm(sqrt(housing.cost) ~
             housing.units.per.acre +
             household.co2 +
             pct.owner.occupied +
             hi.wage.workers.home +
             (jobs.within.45.drive*sqrt(jobs.per.household)))

summary(fit2)

# diagnostic plots indicate homoscedastic residuals
# QQ plot still shows heavy right tail
par(mfrow = c(2, 2))
plot(fit2)
qqPlot(fit2, envelope = .99)

# try generalized linear model with sqrt link function
fit3 <- glm(housing.cost ~
               housing.units.per.acre +
               household.co2 +
               pct.owner.occupied +
               hi.wage.workers.home +
               (jobs.within.45.drive*sqrt(jobs.per.household)), family = poisson(link = "sqrt"))

summary(fit3)

# diagnostic plots
## outlying residuals have too high leverage
par(mfrow = c(2, 2))
plot(fit3)

# try robust linear regression using huber weighting function to address heavy tail
fit4 <- rlm(housing.cost ~
              housing.units.per.acre +
              household.co2 +
              pct.owner.occupied +
              hi.wage.workers.home +
              (jobs.within.45.drive*sqrt(jobs.per.household)), k = 5)

summary(fit4)

# plot model's residuals
par(mfrow = c(2, 2))
boxplot(fit4$wresid); plot(fit4$fitted.values, fit4$wresid)

## weighted model has increased reisdual variance and does not correct tails
## robust regression not more reasonable estimator
## model fit2 errors have mean 0, uncorrelated, with equal variances
## fit2 gives best linear unbiased estimator
## remove insignificant walkable.index variable
fit.final <- lm(sqrt(housing.cost) ~
             housing.units.per.acre +
             household.co2 +
             pct.owner.occupied +
             hi.wage.workers.home +
             (jobs.within.45.drive*sqrt(jobs.per.household)))

summary(fit.final)

# check for multicollinearity in variables combined for jobs
corrgram(all.data[, c("housing.cost", "housing.units.per.acre", "household.co2", "pct.owner.occupied",
                      "hi.wage.workers.home", "jobs.within.45.drive", "jobs.per.household")],
         lower.panel=panel.shade, upper.panel=panel.conf)

vif(fit.final)

# final model diagnostics
par(mfrow = c(2, 2))
plot(fit.final)
qqPlot(fit.final, envelope = .99)

# export relevant dataset (fit.final variables) for Shiny app table
all.data <- all.data[ , c(1, 7, 9, 19, 25, 36, 50, 52)]
all.data <- all.data %>% mutate(weighted.jobs.within.45.drive = jobs.within.45.drive*sqrt(jobs.per.household))

# add zip codes and export
zip.data <- inner_join(xwalk, all.data, by = "GEOID") %>%
  distinct(GEOID, zip, .keep_all = TRUE)

write.csv(zip.data, "zip.data.csv", row.names = FALSE)

# go to create.sp.R to create spatial polygon data frames for Shiny app
