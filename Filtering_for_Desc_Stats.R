## Filtering for Descriptive Stats ##
library(openxlsx)
library(readxl)
library(tidytable)
library(dplyr)
library(lubridate)

# Load Data #
shoot<- read_excel("Penultimate_Shooter(CompleteCounty).xlsx")
x1990 <- read_excel("C:/Users/Owner/OneDrive/Masters Thesis/1990.xlsx")
x2000 <- read_excel("C:/Users/Owner/OneDrive/Masters Thesis/2000.xlsx")
x2010 <- read_excel("C:/Users/Owner/OneDrive/Masters Thesis/2010.xlsx")
x2021 <- read_excel("C:/Users/Owner/OneDrive/Masters Thesis/2021.xlsx")

# Extract Years # 
shoot <- shoot %>%
  mutate(year = year(ymd(date)))

# Align Varnames #
shoot <- shoot %>%
  rename(Year = year)


## Align Vartypes ##
shoot <- shoot  %>%
  mutate(county_fips = as.character(county_fips))

x1990 <- x1990 %>%
  mutate(county_fips= as.character(county_fips))

x2000 <- x2000 %>%
  mutate(county_fips= as.character(county_fips))

x2010 <- x2010 %>%
  mutate(county_fips= as.character(county_fips))

x2021 <- x2021 %>%
  mutate(county_fips= as.character(county_fips))

shoot <- shoot %>%
  mutate(Year = as.numeric(Year))

x1990 <- x1990 %>%
  mutate(Year = as.numeric(Year))

x2000 <- x2000 %>%
  mutate(Year = as.numeric(Year))

x2010<- x2010 %>%
  mutate(Year = as.numeric(Year))

x2021 <- x2021 %>%
  mutate(Year = as.numeric(Year))

# Filter the dataset #
shoot_1990<- shoot %>%
  filter(Year == 1990)

shoot_2000<- shoot %>%
  filter(Year == 2000)

shoot_2010<- shoot %>%
  filter(Year == 2010)

shoot_2021<- shoot %>%
  filter(Year == 2021)


# Merge Data #
m1990<- left_join(x1990, shoot_1990, by = c("county_fips", "Year"))
m2000<- left_join(x2000, shoot_2000, by = c("county_fips", "Year"))
m2010<- left_join(x2010, shoot_2010, by = c("county_fips", "Year"))
m2021<- left_join(x2021, shoot_2021, by = c("county_fips", "Year"))

# Check for Success #
View(m1990)

# Only one shooting in 1990. NA's expected barring the one county where the shooting occurred #

# Export to Excel #
m1990 <- write.xlsx(m1990, "m1990.xlsx")
m2000 <- write.xlsx(m2000, "m2000.xlsx")
m2010 <- write.xlsx(m2010, "m2010.xlsx")
m2021 <- write.xlsx(m2021, "m2021.xlsx")

