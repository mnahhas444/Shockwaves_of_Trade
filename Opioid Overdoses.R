library(readxl)
library(dplyr)
library(tidyr)
library(openxlsx)

Overdoses <- read_excel("Documents/Master's Thesis/Thesis/Opioid Overdoses.xlsx")

years <- 1990:2022

unique_counties <- unique(data[c("State", "County")])

expanded_data <- unique_counties %>%
  crossing(Year = years) %>%
  left_join(Overdoses, by = c("State", "County", "Year")) %>%
  arrange(State, County, Year)

expanded_data$`Crude Rate` <- ifelse(expanded_data$`Crude Rate` == "0.0 (Unreliable)" | expanded_data$`Crude Rate` == "Unreliable" | expanded_data$`Crude Rate` == "Missing", 0, expanded_data$`Crude Rate`)

expanded_data$Deaths_Min <- ifelse(expanded_data$Deaths == "Suppressed", 0, expanded_data$Deaths)

expanded_data$Deaths_Max <- ifelse(expanded_data$Deaths == "Suppressed", 9, expanded_data$Deaths)

write.xlsx(expanded_data, file = "Documents/Master's Thesis/Thesis/opioidrearranged.xlsx")

############################### Regional Overdoses #############################
Regional_Overdoses <- read_excel("Documents/Master's Thesis/Thesis/Regional Overdoses.xlsx")

Regional_Overdoses$Crude_Rate <- ifelse(Regional_Overdoses$Crude_Rate == "0.0 (Unreliable)" | Regional_Overdoses$Crude_Rate == "Unreliable" | Regional_Overdoses$Crude_Rate == "Missing", 0, Regional_Overdoses$Crude_Rate)

expandeddata <- unique_counties %>%
  crossing(Year = years) %>%
  left_join(Regional_Overdoses, by = c("State", "County", "Year")) %>%
  arrange(State, County, Year)

write.xlsx(expandeddata, file = "Documents/Master's Thesis/Thesis/regionaloverdosesedited.xlsx")

################################### Opioid Deaths ##############################
Opioid_Deaths <- read_excel("Documents/Master's Thesis/Thesis/Opioid Deaths.xlsx")


deaths <- Opioid_Deaths %>%
  mutate(Crude_Rate = case_when(
    Crude_Rate == "0.0 (Unreliable)" | Crude_Rate == "Unreliable" ~ 0,
    Crude_Rate == "Suppressed" ~ Crude_Rate,
    TRUE ~ as.numeric(Crude_Rate)
  ))

deaths <- Opioid_Deaths %>%
  mutate(Crude_Rate = as.character(Crude_Rate)) %>%
  mutate(Crude_Rate = case_when(
    Crude_Rate == "0.0 (Unreliable)" | Crude_Rate == "Unreliable" ~ "0",
    Crude_Rate == "Suppressed" ~ Crude_Rate,
    TRUE ~ Crude_Rate
  ))

years <- 1990:2022

unique_counties <- unique(data[c("State", "County")])

expanded_data <- unique_counties %>%
  crossing(Year = years) %>%
  left_join(deaths, by = c("State", "County", "Year")) %>%
  arrange(State, County, Year)

write.xlsx(expanded_data, file = "Documents/Master's Thesis/Thesis/opioid deaths edited.xlsx")


##################################### Rounding #################################

Deaths <- read_excel("~/Documents/Master's Thesis/Thesis/Death_est.xlsx")

df <- mutate(Deaths, rounded_value = ifelse(Deaths$Deaths_Estimate < 1 & Deaths$Deaths_Estimate > 0, 1, round(Deaths$Deaths_Estimate)))

write.xlsx(df, file = "~/Documents/Master's Thesis/Thesis/death_est_edited.xlsx")

