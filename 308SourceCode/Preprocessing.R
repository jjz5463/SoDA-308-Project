library(data.table)
library(tidyverse)

df <- fread('/Users/jiachengzhu/Desktop/project/gun-violence-data_01-2013_03-2018.csv')
df2 <- fread('/Users/jiachengzhu/Desktop/export-d08ddc4a-511b-4e6b-8398-65d3e063a331.csv')
df3 <- fread('/Users/jiachengzhu/Desktop/SoDA-308-Project/308SourceCode/RawData/gun-violence-data_01-2013_03-2018.csv')

df3 <- df3 %>%
  select(!c(incident_url,source_url,sources))

fwrite(df3,'./RawData/historical-violence-data.csv')
