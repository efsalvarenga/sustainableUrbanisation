# load libraries
library(Boruta)

# load previously defined mainDf
if (!exists('mainDf')) {
  source('./20_dataProcessing.R')
}

# drop colnames that would not be used for modeling
dropCols <- c('building_id', 'timestamp', 'site_id')
keepCols <- !colnames(mainDf) %in% dropCols
mainDfM <- mainDf[, keepCols]
respVar <- 'meter_multi_reading'
predVar <- colnames(mainDfM)[!colnames(mainDfM) %in% respVar]



# using only complete cases for variable importance evaluation
mainDfMnonNA <- na.omit(mainDfM)
borutaTest <- Boruta(mainDfMnonNA[, predVar, drop = F], mainDfMnonNA[, respVar, drop = T], holdHistory = F)
saveRDS(borutaTest, './generatedData/borutaTest.rds')
