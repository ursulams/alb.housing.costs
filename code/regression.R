# script to run multiple regression analysis to find factors most influencing housing costs

library(car)
library(leaps)
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
                      overall.employment.index +
                      housing.units.per.acre +
                      employment.mix.index +
                      job.type.mix +
                      walkable.index +
                      pct.single.fam +
                      pct.owner.occupied +
                      num.workers.home +
                      hi.wage.workers.home +
                      hi.wage.workers.work +
                      total.employ +
                      office.jobs +
                      service.jobs +
                      job.type.mix +
                      pct.working.age +
                      jobs.within.45.drive,
                    data = all.data, method = "exhaustive", nbest = 10)

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
            pct.owner.occupied +
            num.workers.home +
            hi.wage.workers.home +
            jobs.within.45.drive)

summary(fit)

# test for  multicollinearity
cor(all.data[c("population", "acreage", "household.co2", "pct.owner.occupied", 
                "num.workers.home", "hi.wage.workers.home", "jobs.within.45.drive")], use = "complete")

# variance inflation factors
# num.workers variable is problematic (>10)
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
                    pct.owner.occupied +
                    num.workers.home +
                    hi.wage.workers.home +
                    jobs.within.45.drive,
                  data = all.data, main = "regression variables")

# second model: remove highly correlated population & num.workers variables
# transform housing cost variable to address fat tail residual distribution
fit2 <- lm(sqrt(housing.cost) ~
             acreage +
             household.co2 +
             pct.owner.occupied +
             hi.wage.workers.home +
             jobs.within.45.drive)

summary(fit2)

# diagnostic plots indicate homoscedastic residuals
# QQ plot still shows heavy right tail
par(mfrow = c(2, 2))
plot(fit2)
crPlots(fit2)
qqPlot(fit2, envelope = .99)

# try robust linear regression using huber weighting function to address heavy tail
fit3 <- rlm(housing.cost ~
              acreage +
              household.co2 +
              pct.owner.occupied +
              hi.wage.workers.home +
              jobs.within.45.drive, k = 5)

summary(fit3)

# plot model's residuals
par(mfrow = c(2, 2))
boxplot(fit3$wresid); plot(fit3$fitted.values, fit3$wresid)

## weighted model has increased reisdual variance and does not correct tails
## robust regression not more reasonable estimator
## model fit2 errors have mean 0, uncorrelated, with equal variances
## fit2 gives best linear unbiased estimator

# export relevant dataset (fit2 variables) for Shiny app table
all.data <- all.data[ , c(1, 4, 7, 9, 25, 36, 52)]

# add zip codes and export
zip.data <- inner_join(xwalk, all.data, by = "GEOID") %>%
  distinct(GEOID, zip, .keep_all = TRUE)

write.csv(zip.data, "zip.data.csv", row.names = FALSE)

# go to create.sp.R
