library(readxl)
library(dplyr)
library(tidyr)
library(openxlsx)
library(lubridate)

################################ collapsing shoot ##############################
df <- read_excel("Documents/Master's Thesis/Thesis/shoot.xlsx")

df$year <- format(as.Date(df$date), "%Y")

df <- subset(df, year >= 1990 & year <= 2022)

df <- df %>%
  group_by(county_fips, year) %>%
  mutate(shoot_count = n()) %>%
  ungroup()

write.xlsx(df, file = "Documents/Master's Thesis/Thesis/shootcount.xlsx")

county_year_counts <- df %>%
  group_by(county_fips) %>%
  summarize(unique_years = n_distinct(Year))

# Identify counties with less than 32 unique years
missing_counties <- county_year_counts %>%
  filter(unique_years < 33)

# Print the missing counties
print(missing_counties)

df <- read_excel("~/Documents/Master's Thesis/Thesis/final1.xlsx")

df <- df %>%
  mutate(shoot_count = if_else(is.na(shoot_count), 0, shoot_count))

write.xlsx(df, file = "Documents/Master's Thesis/Thesis/final.xlsx")
