# load libraries
library(Boruta)
library(dplyr)
library(randomForest)

# load previously defined mainDf
if (!exists('mainDf')) {
  source('./20_dataProcessing.R')
}

# splitting on mainDf for train/test (t/t)
timecol <- sort(unique(mainDf$timestamp))                # define time column for split
splitAt <- timecol[ceiling(length(timecol) * 0.7)]       # define split point

# add t/t split column
mainDf2 <- mainDf %>%
  mutate(train = ifelse(timestamp <= splitAt, T, F))

# check split proportions
sum(mainDf2$train) / length(mainDf2$train)

# drop mainDf2 colnames that would not be used for modeling, subset only train dataset
dropCols <- c('building_id', 'timestamp', 'site_id', 'train')
keepCols <- !colnames(mainDf2) %in% dropCols
mainDfTrain <- mainDf2[mainDf2$train, keepCols]

# define possible prediction variables
respVar <- 'meter_multi_reading'
targVar <- colnames(mainDfTrain)[!colnames(mainDfTrain) %in% respVar]

# perform feature significance test
# run only if it hasn't been evaluated yet
# beware, such evaluation took 1+h on an 8-core i7 processor
if (file.exists('./generatedData/borutaTest.rds')) {
  borutaTest <- readRDS('./generatedData/borutaTest.rds')
  sampleRows <- readRDS('./generatedData/sampleRows.rds')
} else {
  # using only complete cases for proxy on variable importance evaluation
  mainDfMnonNA <- na.omit(mainDfTrain)
  
  # create random sample to make it computationally feasible
  sampleRows <- sample(1:nrow(mainDfMnonNA), 100000)
  mainDfMnonNA <- mainDfMnonNA[sampleRows,]
  
  # run and store test result
  borutaTest <- Boruta(mainDfMnonNA[, targVar, drop = F], mainDfMnonNA[, respVar, drop = T], holdHistory = F)
  saveRDS(borutaTest, './generatedData/borutaTest.rds')
  saveRDS(sampleRows, './generatedData/sampleRows.rds')
}

# extract significant variables
sigVars <- targVar[borutaTest$finalDecision == 'Confirmed']


# imputedData <- rfImpute(mainDfTrain[, sigVars, drop = F], mainDfTrain[, respVar])




model <- randomForest(x = na.omit(mainDfTrain)[sampleRows, sigVars, drop = F],
                      y = na.omit(mainDfTrain)[sampleRows, respVar, drop = T])



