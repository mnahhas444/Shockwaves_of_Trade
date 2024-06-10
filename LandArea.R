library(readxl)
library(dplyr)
library(tidyr)
library(openxlsx)
############################ Land Area by county ##############################
Land_Area <- read_excel("Documents/Master's Thesis/Thesis/Land Area.xlsx")

all_years <- data.frame(year = 1990:2022)  
unique_counties <- unique(Land_Area$CountyCode)  

template_data <- expand.grid(CountyCode = unique_counties, Year = all_years$year)

merged_data <- merge(template_data, Land_Area, by = c("CountyCode", "Year"), all.x = TRUE)

merged_data[is.na(merged_data)] <- NA

write.xlsx(merged_data, file = "Documents/Master's Thesis/Thesis/landareaarranged.xlsx")
