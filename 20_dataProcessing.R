# script will not have exploration as it might be called from other scripts later

# load libraries
library(dplyr)
library(randomForest)

# reload objects, if necessary
if (!exists('dataFolder')) {
  dataFolder <- 'receivedData_DO_NOT_EDIT/'
}

if (!exists('buildingMetadata')) {
  buildingMetadata <- read.csv(paste0(dataFolder, 'building_metadata.csv'))
  buildingMetadata <- na.roughfix(buildingMetadata) # implementing a very rough fix
}

if (!exists('buildingMeterReadings')) {
  buildingMeterReadings <- read.csv(paste0(dataFolder, 'building_meter_readings.csv'))
  buildingMeterReadings$timestamp <- as.POSIXct(buildingMeterReadings$timestamp)
}

if (!exists('weatherData')) {
  weatherData <- read.csv(paste0(dataFolder, 'weather_data.csv'))
  weatherData <- na.roughfix(weatherData) # implementing a very rough fix
  weatherData$timestamp <- as.POSIXct(weatherData$timestamp)
}

# consolidating meter readings from multiple meter on same building
# assumption: meters are installed in parallel
buildingMeterReadingsConsolidated <- buildingMeterReadings %>%
  group_by(building_id, timestamp) %>%
  summarise(meter_multi_reading = sum(meter_reading), .groups = 'drop')

# join building metadata
buildingMeterReadingsConsolidatedMetadata <- left_join(buildingMeterReadingsConsolidated,
                                                       buildingMetadata,
                                                       by = 'building_id')

# join weather data, checking matching cols
matchCols <- colnames(buildingMeterReadingsConsolidatedMetadata)[colnames(buildingMeterReadingsConsolidatedMetadata) %in% colnames(weatherData)]
mainDf <- left_join(buildingMeterReadingsConsolidatedMetadata, weatherData, by = matchCols)
mainDf$timestamp <- as.POSIXct(mainDf$timestamp)


