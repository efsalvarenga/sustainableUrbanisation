# load libraries
library(ggplot2)
library(dplyr)

# set-up params
dataFolder <- 'receivedData_DO_NOT_EDIT/'

# import metadata dataset
buildingMetadata <- read.csv(paste0(dataFolder, 'building_metadata.csv'))

# check uniqueness of id
length(unique(buildingMetadata$building_id))
# means building_id is unique on the table

# number of complete cases, which is useful for modelling choices
sum(complete.cases(buildingMetadata)) / nrow(buildingMetadata)
# many incomplete cases - either a flexible model or imputation will be required

summary(buildingMetadata)

# plot with all 4 dimensions (that was easy :))
ggplot(buildingMetadata, aes(x = year_built, y = square_feet)) +
  geom_point(aes(colour = floor_count)) +
  facet_wrap(~primary_use)
# many missing datapoints, as stated above

# ideas for imputation (if required)
# - bin square_feet per primary_use, interpolate floor year_built
# - bin square_feet and year_built per primary_use, interpolate floor_count
# - could interpolate from energy usage as well, but not if that will be the predictor

# import meter readings dataset
buildingMeterReadings <- read.csv(paste0(dataFolder, 'building_meter_readings.csv'))

# check uniqueness of id, and if all is contained on the metadata
length(unique(buildingMeterReadings$building_id))
sum(unique(buildingMeterReadings$building_id) %in% buildingMetadata$building_id)

# number of complete cases, which is useful for modelling choices
sum(complete.cases(buildingMeterReadings)) / nrow(buildingMeterReadings)

summary(buildingMeterReadings)

# check if multiple meters are metering the same thing on a single building
uniqueBuildingID_meter <- unique(buildingMeterReadings[, c(1,2)])

BuildingID_multipleMeters <- uniqueBuildingID_meter %>%
  group_by(building_id) %>%
  tally() %>%
  filter(n != 1)

# by visually exploring the table below it seems multiple meters are measuring different things
# I will assume they are never in series
buildingMeterReadings[buildingMeterReadings$building_id %in% BuildingID_multipleMeters$building_id,]


weatherData <- read.csv(paste0(dataFolder, 'weather_data.csv'))
