library(tidytable)
library(readxl)
library(openxlsx)

# Load in datasets
shootdf <- read_excel("C:/Users/Owner/OneDrive/Masters Thesis/Compiled Shooter Database (NEEDS EDITS) .xlsx")
us <- read_excel("C:/Users/Owner/OneDrive/Masters Thesis/uscities.xlsx")


# Rename the columns you want to merge as the same name (here you rename state_id as state, first element is the NEW name)
us1 <- us %>% 
  rename(state = state_id)

test <- left_join(shootdf, us1, by = c("state", "city")) # This keeps the first dataset as it is and adds matched columns from the second dataset
# Use the by = to add the columns you want to match on

test1 <- test %>% 
  mutate(fincounty = ifelse(is.na(county), county_name, county))
# This creates a new variable that, if the variable county is an na, uses the value from "county_name". If else, use the value from county

write.xlsx(test1, "fincounty.xlsx")

# We now have 145 na values. We create a new df that keeps (filters) only rows which have NA for fincounty and select only the relevant variables
nocounty <- test1 %>% 
  filter(is.na(fincounty)) %>% 
  select(c(city, state, fincounty, county))

sum(is.na(test1$fincounty))

nocounty <- nocounty %>% 
  mutate(fincounty = city)

countyvector001 <- c("San Ysidro County", "Forsyth County", "Oxford County", "Frederick County", "Dutchess County", "Will County", "Waldo County",  "Dekalb County", "Essex County", "Hillsdale County", "Los Angeles County", "Los Angeles County", "Lauderdale County",
                    "Appomattox County", "Prince George's County", "Chesterfield County", "Nicholas County", "Tulare County", "Greenwood County", "Harris County", "Texas County", "Pima County", "Washington County", "Kitsap County", "Lawrence County", "Boulder County",
                  "St. John the Baptist Parish", "Ramsey County", "Louis County", "Gwynn Oak", "Cumberland County", "St. Louis County", "St. Louis County", "Cuyahoga County", "Miami-Dade County", "St. Louis County", "Forsyth County", "St. Louis County", "El Paso County", 
                  "Queens County", "Prince George's County", "Queens County", "St. Louis County", "St. Clair County", "Ramsey County", "St. Louis County", "King County", "New York County", "Ramsey County", "Ramsey County", "Marlboro County", "Pike County", "St. Louis County",
                  "Pinellas County", "Arapahoe County", "St. Charles Parish", "Forsyth County", "New York County", "St. Clair County", "Orange County", "Clayton County", "St. Clair County", "Frederick County", "St. Louis County", "Prince George's County", "Pike County", "Ramsey County", 
                  "Essex County", "Cowley County", "St. Louis County", "Garland County", "Forsyth County", "San Mateo County", "Nassau County", "El Paso County", "Fulton County", "Nashville County", "New York County", "Halifax County", "Queens County", "Lake County", "Queens County",
                  "Stearns County", "Tallapoosa County", "Los Angeles County", "Los Angeles County", "St. Louis County", "Fulton County", "St. Louis County","Broward County", "Ramsey County", "St. Louis County", "Cecil County", "Miami-Dade County", "Queens County", "Queens County",
                  "New York County", "McLennan County", "Buxchanan County", "Wake County", "St. Louis County", "St. Clair County", "Hidalgo County", "Iron County", "St. Louis County", "Tunica County", "St. Louis County", "Ramsey County", "Los Angeles County", "Nassau County", "Charleston County",
                  "Los Angeles County", "Sagadahoc County", "Forsyth County", "Hancock County", "Clark County", "St. Louis County", "Tunica County", "St Louis County", "Fond du Lac County", "Forsyth County", "St. Louis County", "Prince George's County", "St. Louis County", "Troup County", 
                  "St. Clair County", "Allegheny County", "Cook County", "St. Clair County", "Delaware County", "Warren County", "El Paso County", "Los Angeles County", "Ramsey County", "Cuyahoga County", "Greene County", "Forsyth County", "Pike County", "Clarke County", "Queens County",
                  "Gwynn Oak", "Orange County", "Delaware County", "Pinellas County", "Miami-Dade County")

library(openxlsx)

# Convert object to dataframe
countyvector1 <- as.data.frame(countyvector001)

# Export the dataset as an Excel file
write.xlsx(countyvector1, "vector.xlsx")

