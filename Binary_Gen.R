## Gen Anyshoot variable ##
library(tidytable)
library(dplyr)
library(readxl)
library(openxlsx)
library(lubridate)
## Load Data ##
df<- read_excel("C:/Users/Owner/OneDrive/Masters Thesis/LPMDS4.xlsx")

## Gen anyshoot ##
casualties_by_county <- aggregate(casualties ~ county_fips, df, sum)

## Generate the binary variable indicating if there were any casualties for each county ##
casualties_by_county$anyshoot <- as.numeric(casualties_by_county$casualties > 0)

## Combine ##
df <- merge(df, casualties_by_county[, c("county_fips", "anyshoot")], by = "county_fips", all.x = TRUE)

## Gen Shootcount ##
df<- df %>% 
  select(c(-shootcount))

df<- df %>%
  rename(anyshoot = anyshoot.y)

shoot<- read_excel("C:/Users/Owner/OneDrive/Masters Thesis/Thesis/Penultimate_Shooter(CompleteCounty).xlsx")

shoot <- shoot %>%
  mutate(year = year(ymd(date)))

shoot<- shoot %>% 
  arrange(county_fips, year)

## Create binary for shooting for each county in the window ##
shoot$bin_shoot <- as.numeric(shoot$casualties > 0 | shoot$killed > 0 | shoot$injured > 0)

mass<-as.numeric(shoot$casualties >= 4 | shoot$killed > 0)
sum(shoot$mass)

df$bin_shoot <- as.numeric(df$casualties > 0 | df$killed > 0 | df$injured > 0)

# Calculate the shootcount variable using cumulative sum within each county_fips group
df$shootcount <- ave(df$bin_shoot, df$county_fips, FUN = cumsum)
summary(df$shootcount)


DS<- write.xlsx(df, "REGS.xlsx")
