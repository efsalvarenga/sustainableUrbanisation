# load libraries
library(dplyr)

# reload objects, if necessary
if(!exists('dataFolder')) {
  dataFolder <- 'receivedData_DO_NOT_EDIT/'
}

if(!exists('buildingMetadata')) {
  buildingMetadata <- read.csv(paste0(dataFolder, 'building_metadata.csv'))
}

if(!exists('buildingMeterReadings')) {
  buildingMeterReadings <- read.csv(paste0(dataFolder, 'building_meter_readings.csv'))
}

if(!exists('weatherData')) {
  weatherData <- read.csv(paste0(dataFolder, 'weather_data.csv'))
}

buildingMeterReadingsConsolidated <- buildingMeterReadings %>%
  group_by(building_id, timestamp) %>%
  summarise(meter_multi_reading = sum(meter_reading))
