library(readxl)
library(dplyr)
library(tidyr)
library(openxlsx)
library(readr)

Covariates_Combined <- read_excel("Documents/Master's Thesis/Thesis/Covariates_Combined.xlsx")

any_na <- any(is.na(Covariates_Combined))

unique_counties <- 
  df %>%
  distinct(county_fips) %>%
  nrow()
unique_counties

count_1969 <- sum(Covariates_Combined$Year == 1969, na.rm = TRUE)
count_1969

df <- Covariates_Combined %>%
  mutate(Metro_Nonmetro = ifelse(Total_Pop <= 49999, "nonmetro", "metro"))

df <- df %>%
  mutate(Metro_Nonmetro_Dum = ifelse(Metro_Nonmetro == "metro", 1, 0))

write.xlsx(df, file = "Documents/Master's Thesis/Thesis/metnonmet.xlsx")

# Dropping less than 1990
Covariates_Combined <- Covariates_Combined[Covariates_Combined$Year >= 1990, ]

write.xlsx(Covariates_Combined , file = "Documents/Master's Thesis/Thesis/Covariates1990-2022.xlsx")

################################### Employment #################################

emp <- read_excel("~/Documents/Master's Thesis/Thesis/emp95.xlsx")


emp_long <- pivot_longer(emp, cols = -c(GeoFips, GeoName), names_to = "Year", values_to = "Value")

write.xlsx(emp_long , file = "~/Documents/Master's Thesis/Thesis/emp.xlsx")

############################### Adding opioid intensity ########################

opioid <- read_excel("Documents/Master's Thesis/Thesis/opioid.xlsx")

opioid$iDeaths_Est <- ifelse(opioid$Deaths_Est_Rate >= 0 & opioid$Deaths_Est_Rate <= 10, 1,
                  ifelse(opioid$Deaths_Est_Rate > 10 & opioid$Deaths_Est_Rate <= 25, 2,
                         ifelse(opioid$Deaths_Est_Rate > 25 & opioid$Deaths_Est_Rate <= 50, 3,
                                ifelse(opioid$Deaths_Est_Rate > 50, 4, 4))))

opioid$iDeaths_Max <- ifelse(opioid$Death_Max_Rate >= 0 & opioid$Death_Max_Rate <= 10, 1,
                             ifelse(opioid$Death_Max_Rate > 10 & opioid$Death_Max_Rate <= 25, 2,
                                    ifelse(opioid$Death_Max_Rate > 25 & opioid$Death_Max_Rate <= 50, 3,
                                           ifelse(opioid$Death_Max_Rate > 50, 4, 4))))

opioid$iDeaths_Min <- ifelse(opioid$Death_Min_Rate >= 0 & opioid$Death_Min_Rate <= 10, 1,
                             ifelse(opioid$Death_Min_Rate > 10 & opioid$Death_Min_Rate <= 25, 2,
                                    ifelse(opioid$Death_Min_Rate > 25 & opioid$Death_Min_Rate <= 50, 3,
                                           ifelse(opioid$Death_Min_Rate > 50, 4, 4))))

opioid$iOverdose_Rate <- ifelse(opioid$Overdose_Rate >= 0 & opioid$Overdose_Rate <= 10, 1,
                             ifelse(opioid$Overdose_Rate > 10 & opioid$Overdose_Rate <= 25, 2,
                                    ifelse(opioid$Overdose_Rate > 25 & opioid$Overdose_Rate <= 50, 3,
                                           ifelse(opioid$Overdose_Rate > 50, 4,
                                                  ifelse(opioid$Overdose_Rate == "Suppressed", "Suppressed", 0)))))

opioid$iOverdose_Min <- ifelse(opioid$Overdose_Min_Rate >= 0 & opioid$Overdose_Min_Rate <= 10, 1,
                             ifelse(opioid$Overdose_Min_Rate > 10 & opioid$Overdose_Min_Rate <= 25, 2,
                                    ifelse(opioid$Overdose_Min_Rate > 25 & opioid$Overdose_Min_Rate <= 50, 3,
                                           ifelse(opioid$Overdose_Min_Rate > 50, 4, 4))))

opioid$iOverdose_Max <- ifelse(opioid$Overdose_Max_Rate >= 0 & opioid$Overdose_Max_Rate <= 10, 1,
                               ifelse(opioid$Overdose_Max_Rate > 10 & opioid$Overdose_Max_Rate <= 25, 2,
                                      ifelse(opioid$Overdose_Max_Rate> 25 & opioid$Overdose_Max_Rate <= 50, 3,
                                             ifelse(opioid$Overdose_Max_Rate > 50, 4, 4))))

write.xlsx(opioid , file = "~/Documents/Master's Thesis/Thesis/opioid_intensity.xlsx")

################################# Checking for duplicates ######################

df <- read_excel("~/Documents/Master's Thesis/Thesis/final1.xlsx")


year_counts <- list()

# Loop through years from 1990 to 2022
for (year in 1990:2022) {
  count <- sum(df$Year == year, na.rm = TRUE)
  year_counts[[as.character(year)]] <- count
}

# Print counts for each year
for (year in 1990:2022) {
  cat("Year:", year, ", Count:", year_counts[[as.character(year)]], "\n")
}


counties_with_duplicates <- list()


for (Year in 1990:2022) {
  
  if (year_counts[[as.character(Year)]] > 3109) {
    
    year_data <- df[df$Year == Year, ]
    
    
    duplicate_counties <- unique(year_data$county_fips[duplicated(year_data$county_fips)])
    
    
    counties_with_duplicates[[as.character(Year)]] <- duplicate_counties
  }
}


for (year in 1990:2022) {
  if (year_counts[[as.character(year)]] > 3109) {
    cat("Year:", year, ", Counties with duplicates:", "\n")
    print(counties_with_duplicates[[as.character(year)]])
  }
}

########################## Generating exposure change ##########################
country_emp <- read_excel("Documents/Master's Thesis/Thesis/country_emp.xlsx")


country_data <- country_emp %>%
  group_by(Year) %>%
  summarize(
    manufacturing = sum(`Observation Value`, na.rm = TRUE)  
  ) %>%
  ungroup()

emp_est <- read_excel("Documents/Master's Thesis/Thesis/Beginning Sets/merged_emp_est.xlsx")

country_emp_merged <- merge(emp_est, country_data, by = "Year", all = TRUE)

write.xlsx(country_emp_merged, file = "~/Documents/Master's Thesis/Thesis/country_emp_merged.xlsx")


df <- read_excel("~/Documents/Master's Thesis/Thesis/compact6.xlsx")

df <- df %>%
  group_by(county_fips) %>%
  mutate(exposure_est_change = c(NA, diff(exposure_est))) %>%
  ungroup()

df <- df %>%
  mutate(exposure_est_change = replace(exposure_est_change, is.na(exposure_est_change), 0))

write.xlsx(df, file = "~/Documents/Master's Thesis/Thesis/compact5.xlsx")

## generating change in share ##

df <- read_excel("~/Documents/Master's Thesis/Thesis/compact7.xlsx")


df <- df %>%
  group_by(county_fips) %>%
  mutate(pemp_change = c(NA, diff(pempest))) %>%
  ungroup()

df <- df %>%
  mutate(pemp_change = replace(pemp_change, is.na(pemp_change), 0))

write.xlsx(df, file = "~/Documents/Master's Thesis/Thesis/pempchange.xlsx")

##################### Generating exposure percentiles #######################
df <- read_excel("~/Documents/Master's Thesis/Thesis/Beginning Sets/compact5.xlsx")

# Calculate the percentiles for exposure
p25 <- quantile(df$exposure_est_change, 0.25, na.rm = TRUE)
p50 <- quantile(df$exposure_est_change, 0.50, na.rm = TRUE)
p75 <- quantile(df$exposure_est_change, 0.75, na.rm = TRUE)

# Create a categorical variable based on the percentiles
df <- df %>%
  mutate(
    exposurep = case_when(
      exposure_est_change < p25 ~ 1,
      exposure_est_change >= p25 & exposure_est_change < p50 ~ 2,
      exposure_est_change >= p50 & exposure_est_change < p75 ~ 3,
      exposure_est_change >= p75 ~ 4
    )
  )


write.xlsx(df, file = "~/Documents/Master's Thesis/Thesis/compact7.xlsx")

############################### Changing FOR ##################################
df <- read_excel("~/Documents/Master's Thesis/Thesis/compact5.xlsx")

df <- df %>%
  mutate(FOR = abs(FOR))

write.xlsx(df, file = "~/Documents/Master's Thesis/Thesis/compact5.xlsx")

################################### voting ######################################
voting <- read_excel("~/Documents/Master's Thesis/Thesis/compact12.xlsx")

most_votes <- voting %>%
  group_by(Year, county_fips) %>%
  filter(candidatevotes == max(candidatevotes)) %>%
  ungroup()

unique(voting$party)

votes <- most_votes %>%
  mutate(class = ifelse(party %in% c("REPUBLICAN", "LIBERTARIAN", "OTHER"), 1, 0))

votes <- votes %>%
  arrange(county_fips, Year)

# Create a lagged version of wing_class
votes <- votes %>%
  group_by(county_fips) %>%
  mutate(class_lag = lag(class)) %>%
  ungroup()

# Create the change indicator
df <- voting %>%
  mutate(change_rep = case_when(
    is.na(class_lag) ~ 0,  # No change for the first year
    class == class_lag ~ 0,  # No change
    class == 0 & class_lag == 1 ~ 1  # Change from 0 to 1
  ))
df <- df %>%
  mutate(change_dem = case_when(
    is.na(class_lag) ~ 0,  # No change for the first year
    class == class_lag ~ 0,  # No change
    class == 1 & class_lag == 1 ~ 1  # Change from 0 to 1
  ))

write.xlsx(df, file = "~/Documents/Master's Thesis/Thesis/df.xlsx")


################################ suicides #####################################

suicides <- read_excel("~/Documents/Master's Thesis/Thesis/suicides.xlsx")
regional_suicides <- read_excel("~/Documents/Master's Thesis/Thesis/regional_suicides.xlsx")

census_regions <- data.frame(
  State = c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut",
            "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana",
            "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts",
            "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", 
            "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", 
            "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", 
            "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", 
            "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"),
  Region = c("South", "West", "West", "South", "West", "West", "Northeast",
             "South", "South", "South", "West", "West", "Midwest", "Midwest",
             "Midwest", "Midwest", "South", "South", "Northeast", "South", "Northeast",
             "Midwest", "Midwest", "South", "Midwest", "West", "Midwest", 
             "West", "Northeast", "Northeast", "West", "Northeast", "South", 
             "Midwest", "Midwest", "South", "West", "Northeast", "Northeast", 
             "South", "Midwest", "South", "South", "West", "Northeast", 
             "South", "West", "South", "Midwest", "West"))

states_with_regions <- left_join(suicides, census_regions, by = "State")

combined_suicides <- left_join(states_with_regions, regional_suicides, by = c("Region", "Year"))

write.xlsx(combined_suicides, file = "~/Documents/Master's Thesis/Thesis/combined_suicides.xlsx")

df <- read_excel("~/Documents/Master's Thesis/Thesis/combined_suicides.xlsx")

df$Suicides_Min <- ifelse(df$suicide_count == "Suppressed", 0, df$suicide_count)

df$Suicides_Max <- ifelse(df$suicide_count == "Suppressed", 9, df$suicide_count)

write.xlsx(df, file = "~/Documents/Master's Thesis/Thesis/suicide_total.xlsx")


