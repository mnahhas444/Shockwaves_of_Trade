## Manufacture Pivot ##
## Setup ##
library(stringr)
library(dplyr)
library(tidytable)
library(readxl)
library(tidyr)
library(openxlsx)
library(readr)

## Load ##
df<- read_excel("C:/Users/Owner/OneDrive/Masters Thesis/Manufacture_2001_2022.xlsx")

## Remove Irrelevant ##
cleaned_df <- df %>%
  select(-c(Region, TableName, LineCode, Unit, IndustryClassification))

## Filter for Manufacturing ##
df_filtered <- cleaned_df %>%
  filter(Description == "Manufacturing")
View(df_filtered)

## Drop After Filter ##
cleaned_df2 <- df_filtered %>%
  select(-c(Description))

## Remove NAs ##
df <- cleaned_df2 %>%
  mutate_all(~ ifelse(. == "(D)", 0, .))

## Create New Year Columns ##
new_years <- data.frame(matrix(0, nrow = nrow(df), ncol = 2000 - 1990 + 1))
colnames(new_years) <- paste0(1990:2000)

## Bind Columns ##
df <- df %>%
  select(GeoFIPS, GeoName, everything()) %>%
  bind_cols(new_years)

## Reorganize ##
df <- df %>%
  select(GeoFIPS, GeoName, paste0(1990:2000), everything())

## Align Vartypes ##
df<- df %>%
  mutate(across("2001":"2022", as.numeric))

## Pivot to Long ##
pivoted <- df %>%
  pivot_longer(cols = -c(GeoFIPS, GeoName), # Select all columns except geo_fips and geo_name
               names_to = "Year",
               values_to = "Jobs")

## Remove Variable Quotes ##
pivoted$GeoFIPS <- gsub('"', '', pivoted$GeoFIPS)

## Remove Variable Asterisks ##
pivoted$GeoName <- gsub("\\*$", "", pivoted$GeoName)

## Load Merge Data ##
merge<- read_excel("C:/Users/Owner/OneDrive/Masters Thesis/merged_for_merge.xlsx")

## Remove Variable Asterisks ##
merge$County <- gsub("\\*$", "", merge$County)

piv<- pivoted

## Find unique county_fips in the "merge" dataset ##
merge_county_fips <- unique(merge$County)

## Find unique county_fips in the "piv" dataset ##
piv_county_fips <- unique(piv$GeoName)

## Find county_fips that are in "piv" but not in "merge" ##
extra_piv_county_fips <- setdiff(piv_county_fips, merge_county_fips)

## Find county_fips that are in "merge" but not in "piv" ##
extra_merge_county_fips <- setdiff(merge_county_fips, piv_county_fips)

## Output the results ##
print(extra_piv_county_fips)
print(extra_merge_county_fips)

## Remove Redundancies ##
piv <- piv %>%
  filter(!GeoName %in% c("United States", "Alabama", "Alaska", "Aleutians East Borough, AK", "Aleutians West Census Area, AK",
                         "Anchorage Municipality, AK", "Bethel Census Area, AK", "Bristol Bay Borough, AK",
                         "Chugach Census Area, AK", "Copper River Census Area, AK", "Denali Borough, AK",
                         "Dillingham Census Area, AK", "Fairbanks North Star Borough, AK", "Haines Borough, AK",
                         "Hoonah-Angoon Census Area, AK", "Juneau City and Borough, AK", "Kenai Peninsula Borough, AK",
                         "Ketchikan Gateway Borough, AK", "Kodiak Island Borough, AK", "Kusilvak Census Area, AK",
                         "Lake and Peninsula Borough, AK", "Matanuska-Susitna Borough, AK", "Nome Census Area, AK",
                         "North Slope Borough, AK", "Northwest Arctic Borough, AK", "Petersburg Borough, AK",
                         "Prince of Wales-Hyder Census Area, AK", "Prince of Wales-Outer Ketchikan Census Area, AK",
                         "Sitka City and Borough, AK", "Skagway Municipality, AK", "Skagway-Hoonah-Angoon Census Area, AK",
                         "Southeast Fairbanks Census Area, AK", "Valdez-Cordova Census Area, AK", "Wrangell City and Borough, AK",
                         "Wrangell-Petersburg Census Area, AK", "Yakutat City and Borough, AK", "Yukon-Koyukuk Census Area, AK",
                         "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "District of Columbia",
                         "Florida", "Georgia", "Hawaii", "Hawaii, HI", "Honolulu, HI", "Kauai, HI", "Maui + Kalawao, HI",
                         "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
                         "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri",
                          "Montana", "Nebraska", "Nevada",
                         "New Hampshire", "New Jersey", "New Mexico", "Cibola, NM", "Valencia, NM", "New York", "North Carolina",
                         "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
                         "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia",
                         "Albemarle + Charlottesville, VA", "Alleghany + Covington, VA", "Augusta, Staunton + Waynesboro, VA",
                         "Campbell + Lynchburg, VA", "Carroll + Galax, VA", "Dinwiddie, Colonial Heights + Petersburg, VA",
                         "Fairfax, Fairfax City + Falls Church, VA", "Frederick + Winchester, VA", "Greensville + Emporia, VA",
                         "Henry + Martinsville, VA", "James City + Williamsburg, VA", "Montgomery + Radford, VA", "Pittsylvania + Danville, VA",
                         "Prince George + Hopewell, VA", "Prince William, Manassas + Manassas Park, VA", "Roanoke + Salem, VA",
                         "Rockbridge, Buena Vista + Lexington, VA", "Rockingham + Harrisonburg, VA", "Southampton + Franklin, VA",
                         "Spotsylvania + Fredericksburg, VA", "Washington + Bristol, VA", "Wise + Norton, VA", "York + Poquoson, VA",
                         "Washington", "West Virginia", "Wisconsin", "Wyoming", "New England", "Mideast", "Great Lakes", "Plains",
                         "Southeast", "Southwest", "Rocky Mountain", "Far West"))

## Align Varnames ##
piv<- piv %>% 
  rename(county_fips = GeoFIPS)

## Align Vartypes ##
piv <- piv %>%
  mutate(county_fips = as.character(county_fips))

merge<- merge %>%
  mutate(county_fips= as.character(county_fips))

piv <- piv %>%
  mutate(Year = as.numeric(Year))

merge<- merge %>%
  mutate(Year = as.numeric(Year))

## LeftJoin to Final Data ##
Dataset<- left_join(piv, merge, by = c("county_fips", "Year"))

## Add Binary Indicator ##
Dataset <- Dataset %>%
  mutate(shoot = ifelse(killed > 0 | casualties > 0 | injured > 0, 1, 0))
print(Dataset$shoot)

## Output to Excel ##
ds<- write.xlsx(Dataset, "LPMDS.xlsx")
