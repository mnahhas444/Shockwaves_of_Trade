library(readxl)
library(dplyr)
library(tidyr)
library(openxlsx)

########################### Merging with Opioid Overdoses #####################

Covariates <- read_excel("Documents/Master's Thesis/Thesis/Covariates1990-2022.xlsx")
overdoses <- read_excel("Documents/Master's Thesis/Thesis/opioid overdoses.xlsx")

merged_data <- merge(Covariates, overdoses, by = c("CountyCode", "Year"), all = TRUE)

write.xlsx(merged_data, file = "Documents/Master's Thesis/Thesis/merged.xlsx")

#### filling in NA values with 0

merged <- read_excel("Documents/Master's Thesis/Thesis/merged.xlsx")

filled_merged <- merged %>%
  mutate(across(everything(), ~ifelse(is.na(.), 0, .)))

############################## Merging with Land Area ###########################

landareaarranged <- read_excel("Documents/Master's Thesis/Thesis/landareaarranged.xlsx")

merged_data <- merge(filled_merged, landareaarranged, by = c("CountyCode", "Year"), all = TRUE)

write.xlsx(merged_data, file = "Documents/Master's Thesis/Thesis/merged2.xlsx")


########################## Merging with Opioid Deaths ###########################

opioid_deaths_edited <- read_excel("Documents/Master's Thesis/Thesis/opioid deaths edited.xlsx")

Regional_Deaths <- read_excel("Documents/Master's Thesis/Thesis/Regional Deaths.xlsx")

merged_data <- merge(opioid_deaths_edited, Regional_Deaths, by = c("Region", "Year"), all = TRUE)

write.xlsx(merged_data, file = "Documents/Master's Thesis/Thesis/opioid merged.xlsx")

################### Merging covariates with opioid deaths ######################

opioid_merged <- read_excel("Documents/Master's Thesis/Thesis/opioid merged.xlsx")

merged2 <- read_excel("Documents/Master's Thesis/Thesis/merged2.xlsx")

merge3 <- merge(merged2, opioid_merged, by = c("CountyCode", "Year"), all = TRUE)

write.xlsx(merge3, file = "Documents/Master's Thesis/Thesis/merge3.xlsx")

########################## Merging with Laws ####################################

merge3 <- read_excel("Documents/Master's Thesis/Thesis/merge3.xlsx")

law_rank <- read_excel("Documents/Master's Thesis/Thesis/law_rank.xlsx")

merged4 <- merge(merge3, law_rank, by = c("State", "Year"), all = TRUE)

write.xlsx(merged4, file = "Documents/Master's Thesis/Thesis/merged4.xlsx")

######################### Merging with FOR ###################################

df <- read_excel("Documents/Master's Thesis/Thesis/First_Draft_Dataset.xlsx")

FOR <- read_excel("Documents/Master's Thesis/Public Term Paper/Public Data/Beginning Sets/State-Level Estimates of Household Firearm Ownership.xlsx", 
                                                                   sheet = "State-Level Data & Factor Score")
FOR <- FOR[FOR$Year >= 1990, ]

FOR <- FOR[FOR$State_FIPS != 2 & FOR$State_FIPS != 15, ]

merged5 <- merge(df, FOR, by = c("State", "Year"), all = TRUE)

write.xlsx(merged5, file = "Documents/Master's Thesis/Thesis/merged5.xlsx")

######################## Merging with Poverty #################################
df <- read_excel("Documents/Master's Thesis/Thesis/poverty1993.xlsx")

df <- df[df$County_FIPS != 0, ]

df <- df[!(df$State_FIPS %in% c(2, 15)), ]

merged5 <- read_excel("Documents/Master's Thesis/Thesis/merged5.xlsx")

merged6 <- merge(merged5, df, by = c("State_FIPS", "County_FIPS", "Year"), all = TRUE)

write.xlsx(merged6, file = "Documents/Master's Thesis/Thesis/merged6.xlsx")

######################## Merging with Manufacturing ###########################

fips <- read_excel("~/Documents/Master's Thesis/Thesis/fips.xlsx")

mf <- read_excel("Manufacture_2001_2022.xlsx")

### cleaning the manufacturing dataset

mf <- subset(mf, !grepl("0$", county_fips))

mf <- mf %>%
  filter(Description == "Manufacturing")

mf_pivot <- pivot_longer(mf, cols = -c(county_fips, GeoName, Description), names_to = "Year", values_to = "Value")

mf_wide <- pivot_wider(mf_pivot, names_from = Description, values_from = Value)

mf_wide$Manufacturing <- ifelse(mf_wide$Manufacturing == "(D)", 0, mf_wide$Manufacturing)

years <- 1990:2000
county_fips <- unique(mf_wide$county_fips) 
county_year_combinations <- expand.grid(county_fips = county_fips, Year = years)

new_df <- merge(county_year_combinations, mf_wide, by = c("county_fips", "Year"), all = TRUE)

new_df$Manufacturing[is.na(new_df$Manufacturing)] <- 0

merged_mf <- merge(fips, new_df, by = c("county_fips", "Year"), all = TRUE)

write.xlsx(merged_mf, file = "merged_mf.xlsx")

LPMDS <- read_excel("~/Documents/Master's Thesis/Thesis/LPMDS.xlsx")

if (any(is.na(LPMDS4))) {
  print("There are missing values (NAs) in the dataset.")
} else {
  print("There are no missing values (NAs) in the dataset.")
}

columns_with_NAs <- colSums(is.na(LPMDS4))

# Display columns with NAs
print(columns_with_NAs)
####################### Merging with employment ###########################

LPMDS4 <- read_excel("~/Documents/Master's Thesis/Thesis/LPMDS4.xlsx")

emp <- read_excel("~/Documents/Master's Thesis/Thesis/Beginning Sets/emp.xlsx")

merged_emp <- merge(LPMDS3, emp, by = c("county_fips", "Year"), all = TRUE)

write.xlsx(merged_emp, file = "~/Documents/Master's Thesis/Thesis/LPMDS4.xlsx")

###################### Merging for county estimates ##########################
mf <- read_excel("~/Documents/Master's Thesis/Thesis/manufacturing_est.xlsx")
state_share <- read_excel("~/Documents/Master's Thesis/Thesis/Beginning Sets/state_share.xlsx")

merged <- merge(mf, state_share, by = c("State", "Year"), all = TRUE)

write.xlsx(merged, file = "~/Documents/Master's Thesis/Thesis/manufacturing_est1.xlsx")

year_counts <- list()

# Loop through years from 1990 to 2022
for (year in 1990:2022) {
  count <- sum(merged$Year == year, na.rm = TRUE)
  year_counts[[as.character(year)]] <- count
}

# Print counts for each year
for (year in 1990:2022) {
  cat("Year:", year, ", Count:", year_counts[[as.character(year)]], "\n")
}

write.xlsx(merged, file = "~/Documents/Master's Thesis/Thesis/merged_emp_est.xlsx")

############################# merging with inequality #########################

Gini_1990 <- read_excel("Documents/Master's Thesis/Thesis/Gini_1990.xlsx")

Gini_2000 <- read_excel("Documents/Master's Thesis/Thesis/Gini_2000.xlsx")

Gini_2010 <- read_excel("Documents/Master's Thesis/Thesis/Gini_2010.xlsx")

compact8 <- read_excel("Documents/Master's Thesis/Thesis/compact8.xlsx")

gini1990_2000 <- merge(Gini_1990, Gini_2000, by = c("county_fips", "Year", "GINI"), all = TRUE)

Gini_2010$GINI <- Gini_2010$GINI/100

gini2000_2010 <- merge(gini1990_2000, Gini_2010, by = c("county_fips", "Year", "GINI"), all = TRUE)

merged <- merge(compact8, gini2000_2010, by = c("county_fips", "Year"), all = TRUE)

write.xlsx(merged, file = "~/Documents/Master's Thesis/Thesis/compact9.xlsx")

########################### merging with voting #############################

df <- read_excel("Documents/Master's Thesis/Thesis/compact9.xlsx")

vote_merged <- merge(df, votes, by = c("county_fips", "Year"), all = TRUE)

write.xlsx(vote_merged, file = "~/Documents/Master's Thesis/Thesis/compact10.xlsx")

############################ merging with suicides ############################

suicide_total <- read_excel("~/Documents/Master's Thesis/Thesis/suicide_total.xlsx")

df <- read_excel("~/Documents/Master's Thesis/Thesis/compact10.xlsx")

compact11 <- merge(df, suicide_total, by = c("county_fips", "Year"), all = TRUE)

write.xlsx(compact11, file = "~/Documents/Master's Thesis/Thesis/compact11.xlsx")

############################### merging with TAA ##############################

df <- read_excel("~/Documents/Master's Thesis/Thesis/compact11.xlsx")

TAA_total <- read_excel("~/Documents/Master's Thesis/Thesis/TAA_total.xlsx")

df <- merge(df, TAA_total, by = c("State", "Year"), all = TRUE)

write.xlsx(df, file = "~/Documents/Master's Thesis/Thesis/compact12.xlsx")


########################## merging with shootcount ############################
shootcount1 <- read_excel("Documents/Master's Thesis/Thesis/shootcount1.xlsx")

final <- read_excel("Documents/Master's Thesis/Thesis/Code and Excel/final.xlsx")

df <- merge(final, shootcount1, by = c("county_fips", "Year"), all = TRUE)

write.xlsx(df, file = "~/Documents/Master's Thesis/Thesis/final1.xlsx")




