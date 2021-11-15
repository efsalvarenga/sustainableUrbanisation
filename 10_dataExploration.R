# load libraries
library(readr)
library(ggplot2)

# set-up params
dataFolder <- 'receivedData_DO_NOT_EDIT/'

# import metadata dataset
buildingMetadata <- read_csv(paste0(dataFolder, 'building_metadata.csv'))

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
buildingMeterReadings <- read_csv(paste0(dataFolder, 'building_meter_readings.csv'))

# check uniqueness of id, and if all is contained on the metadata
length(unique(buildingMeterReadings$building_id))
sum(unique(buildingMeterReadings$building_id) %in% buildingMetadata$building_id)

# number of complete cases, which is useful for modelling choices
sum(complete.cases(buildingMeterReadings)) / nrow(buildingMeterReadings)

summary(buildingMeterReadings)

unique(buildingMeterReadings[, c(1,2)])



# import weather dataset
weatherData <- read.csv(paste0(dataFolder, 'weather_data.csv'))

# check uniqueness of id, and if all is contained on the metadata
length(unique(weatherData$site_id))
sum(unique(weatherData$site_id) %in% buildingMetadata$site_id)
sum(unique(buildingMetadata$site_id) %in% unique(weatherData$site_id))

# now I know that building_id maps to metadata, site_id maps to weather data
