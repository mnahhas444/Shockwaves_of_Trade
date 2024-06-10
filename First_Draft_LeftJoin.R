## Left Join of Shooter Database to SEER Data ## 
library(tidytable)
library(readxl)
library(openxlsx)
library(dplyr)
library(lubridate)

## Load Data ##
shoot<-read_excel("C:/Users/Owner/OneDrive/Masters Thesis/Thesis/Penultimate_Shooter(CompleteCounty).xlsx")
merged <- read_excel("C:/Users/Owner/OneDrive/Masters Thesis/merged4.xlsx")
View(shoot)
View(merged)


## Extract Years ## 
shoot <- shoot %>%
  mutate(year = year(ymd(date)))

## Extract Relevant Columns ##

shoot1 <- subset(shoot, select = c("year", "killed", "injured", "casualties", "county_fips"))
View(shoot1)

## Aggregate ##
agg_shoot <- aggregate(. ~ year + county_fips, data = shoot1, FUN = mean, na.rm = TRUE, na.action = na.omit)


## Prep for LeftJoin ##
merged <- merged %>% 
  rename(county_fips = CountyCode)
merged<- merged %>%
  rename(year = Year)
merged <- merged %>%
  mutate(year = as.numeric(year))

agg_shoot <- agg_shoot %>%
  mutate(year = as.numeric(year))


## Left Join ##
Dataset <- left_join(merged, agg_shoot, by = c("year", "county_fips" ))
library(tidyr)

# Replace NA values with zeros in the relevant columns #
Dataset_firstdraft <- Dataset %>%
  mutate(across(c(killed, injured, casualties), ~replace_na(., 0)))

# Print to Excel #
First_Draft_Dataset<-write.xlsx(Dataset_firstdraft, "First_Draft_Dataset.xlsx")
