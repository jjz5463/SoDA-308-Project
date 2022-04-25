# library
library(data.table)
library(tidyverse)

# load all the datasets
Gun2019 <- fread('./308SourceCode/RawData/2019Gun.csv')
AllYearGun <- fread('./308SourceCode/RawData/allYearGun.csv')
education <- fread('./308SourceCode/RawData/Education.csv')
population <- fread('./308SourceCode/RawData/PopulationEstimates.csv')
unemployment <- fread('./308SourceCode/RawData/Unemployment.csv')
hisViolence <- fread('./308SourceCode/RawData/historical-violence-data.csv')
income <- fread('./308SourceCode/RawData/Income.csv')
job <- fread('./308SourceCode/RawData/Jobs.csv')
veterans <- fread('./308SourceCode/RawData/Veterans.csv')
people <- fread('./308SourceCode/RawData/People.csv')
