# library
library(data.table)
library(tidyverse)
library(lubridate)

# load all the datasets
Gun2019 <- fread('./308SourceCode/RawData/2019Gun.csv') # did not use
AllYearGun <- fread('./308SourceCode/RawData/allYearGun.csv')
education <- fread('./308SourceCode/RawData/Education.csv')
population <- fread('./308SourceCode/RawData/PopulationEstimates.csv')
unemployment <- fread('./308SourceCode/RawData/Unemployment.csv')
hisViolence <- fread('./308SourceCode/RawData/historical-violence-data.csv') # did not use
income <- fread('./308SourceCode/RawData/Income.csv')
job <- fread('./308SourceCode/RawData/Jobs.csv')
veterans <- fread('./308SourceCode/RawData/Veterans.csv')
people <- fread('./308SourceCode/RawData/People.csv')
stateCode <- fread('./308SourceCode/RawData/stateCode.csv')

# clear up all gun violence data and select feature we want
## 2018 - 2022
AllYearGun <- AllYearGun %>%
  select('Incident ID','Incident Date', 'State', 'City Or County', '# Killed', '# Injured') %>%
  mutate(IncYear = str_extract(`Incident Date`,"\\d{4}$")) %>%
  mutate(n_totVictim = `# Killed` + `# Injured`) %>%
  mutate(n_killed = `# Killed`) %>%
  mutate(n_injured = `# Injured`) %>%
  mutate(city_or_county = `City Or County`) %>%
  mutate(state = State) %>%
  select('Incident ID','state', 'city_or_county', 'n_killed', 'n_injured', 'IncYear', 'n_totVictim')

## since this dataset already cover the 2019, we give up Gun2019 df
AllYearGun %>%
  group_by(IncYear) %>%
  summarise(count = n())

## 2013 to 2018 gun violence
hisViolence <- hisViolence %>%
  select('date', 'state', 'city_or_county', 'n_killed','n_injured') %>%
  mutate(IncYear = year(date)) %>%
  mutate(n_totVictim = n_killed + n_injured) %>%
  select('state', 'city_or_county', 'n_killed','n_injured','IncYear','n_totVictim')

## does not seems to fit with trend from 2018 to 2022, will not use
hisViolence %>%
  group_by(IncYear) %>%
  summarise(count = n())

# clear up poverty
income <- income %>%
  select('State','County','PCTPOVALL', 'PCTPOV017',
         'Median_HH_Inc_ACS', ,'MedHHInc', 
         'Poverty_Rate_0_17_ACS', 'Poverty_Rate_ACS',
         'Deep_Pov_All','Deep_Pov_Children') %>%
  mutate(povRate_19 = PCTPOVALL) %>%
  mutate(povRate_minor_19 = PCTPOV017) %>%
  mutate(median_income_15_19 = Median_HH_Inc_ACS) %>%
  mutate(median_income_19 = MedHHInc) %>%
  mutate(povRate_minor_15_19 = Poverty_Rate_0_17_ACS) %>%
  mutate(poveRate_15_19 = Poverty_Rate_ACS) %>%
  mutate(deepPov = Deep_Pov_All) %>%
  mutate(deepPov_minor = Deep_Pov_Children) %>%
  select('State', 'County', 'povRate_19', 'povRate_minor_19',
         'poveRate_15_19','povRate_minor_15_19',
         'median_income_15_19', 'median_income_19',
         'deepPov', 'deepPov_minor')

# clear up control variables
education <- education %>%
  select('State', 'Area name', 'Percent of adults with less than a high school diploma, 2015-19',
         'Percent of adults with a high school diploma only, 2015-19',
         `Percent of adults with a bachelor's degree or higher, 2015-19`) %>%
  mutate(noHighSch_15_19 = `Percent of adults with less than a high school diploma, 2015-19`) %>%
  mutate(highSch_15_19 = `Percent of adults with a high school diploma only, 2015-19`) %>%
  mutate(bachelor_15_19 = `Percent of adults with a bachelor's degree or higher, 2015-19`) %>%
  mutate(county = `Area name`) %>%
  select('State', 'county', noHighSch_15_19, highSch_15_19, bachelor_15_19)

job <- job %>%
  select('State', 'County', 'UnempRate2020', 'UnempRate2019', 'UnempRate2018', 'UnempRate2017')

people <- people %>%
  select('State', 'County', 'PopChangeRate1019') 

population <- population %>%
  select('State', 'Area name', 'Population 2020') %>%
  mutate(county = `Area name`) %>%
  select('State', 'county', 'Population 2020')

unemployment <- unemployment %>%
  select('State', 'Area_name', 'Unemployment_rate_2018',
         'Unemployment_rate_2019', 'Unemployment_rate_2020')

veterans <- veterans %>%
  select('State', 'County', 'LFPVetsRate')

# combine poverty data with gun violence data
stateCode <- stateCode %>%
  select('State', 'Code')

train <- AllYearGun %>%
  group_by(state, city_or_county,IncYear) %>%
  summarise(n_killed = sum(n_killed), n_injured = sum(n_injured), n_totVictim = sum(n_totVictim)) %>%
  left_join(stateCode, by = c('state' = 'State')) %>%
  inner_join(income, by = c('Code' = 'State','city_or_county' = 'County'))

# combine control variables (education, job, people, population, veterans)
education <- education %>%
  mutate(county = gsub(' County',"", county))

population <- population %>%
  mutate(county = gsub(' County',"", county))

control <- education %>%
  inner_join(job, by = c('State' = 'State', 'county' = 'County')) %>%
  inner_join(people, by = c('State' = 'State', 'county' = 'County')) %>%
  inner_join(population, by = c('State','county')) %>%
  inner_join(veterans, by = c('State','county' = 'County'))

# combine train and control
Train <- train %>%
  inner_join(control, by = c('Code' = 'State','city_or_county' = 'county'))

# fwrite
fwrite(Train, "./308SourceCode/ProcessedData/Train.csv")
