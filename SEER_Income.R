library(readxl)
library(dplyr)
library(tidyr)
library(openxlsx)
library(readr)

seer_data <- read_csv("Documents/Master's Thesis/Thesis/seer_data_parsed.csv")

cleaned_df <- seer_data %>%
  select(-c(Origin, Registry))

pivoted_df <- cleaned_df %>%
  pivot_wider(names_from = c(Race, Sex, Age), values_from = Population)

ordered_df <- pivoted_df %>%
  arrange(State_FIPS, County_FIPS, Year)

write.xlsx(ordered_df, file = "Documents/Master's Thesis/Thesis/seer_data_edited.xlsx")

Income_US <- read_excel("Documents/Master's Thesis/Thesis/Income_US.xlsx")

pivoted <- Income_US %>%
  pivot_longer(cols = -c(GeoFips, GeoName), # Select all columns except geo_fips and geo_name
               names_to = "Year",
               values_to = "Income")

write.xlsx(pivoted, file = "Documents/Master's Thesis/Thesis/income_pivoted.xlsx")