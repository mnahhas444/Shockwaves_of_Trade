## Prediction of FOR 2017-2022 ##
library(lubridate)
library(dplyr)
library(readxl)
library(openxlsx)
library(lme4)
library(ggplot2)


## Impute 0's with NA's ##
data <- data %>%
  mutate(FOR = ifelse(Year > 2016 & FOR == 0, NA, FOR))

## Fit Mixed Effects Model with Random Slopes for Year ##
model <- lmer(FOR ~ Year + HH_Income + PopDen + Poverty + Percent_Poverty + Manufacturing + Total_emp + Deaths_Est_Rate + Law_Rank + (Year | county_fips), data = data)

## Create pred_variable ##
data_pred <- data

## Predict FOR ##
data_pred$FOR_pred <- predict(model, newdata = data_pred, allow.new.levels = TRUE)

## Update FOR_pred column with NA for years before 2017 ##
data_pred$FOR_pred[data_pred$Year <= 2016] <- NA

## Update FOR column with predicted values where it's currently NA ##
data_pred$FOR <- ifelse(is.na(data_pred$FOR), data_pred$FOR_pred, data_pred$FOR)

## Get both actual and predicted FOR values ##
data_combined <- data_pred %>%
  mutate(FOR_actual = ifelse(Year <= 2016, FOR, NA))

## Get unique county_fips codes ##
unique_counties <- unique(data_combined$county_fips)

## Randomly select 4 county_fips codes ##
set.seed(123)  # for reproducibility
selected_counties <- sample(unique_counties, 4)

## Filter data for the selected counties ##
data_selected <- data_combined %>%
  filter(county_fips %in% selected_counties)

## Join with original data to get county names ##
data_selected <- data_selected %>%
  left_join(data %>% select(county_fips, County) %>% distinct(), by = "county_fips")

## Plot the Trends for the selected counties ##
ggplot(data_selected, aes(x = Year)) +
  geom_point(aes(y = FOR, color = County.x)) +
  geom_line(aes(y = FOR, group = County.x, color = County.x)) + 
  geom_point(aes(y = FOR_pred), color = "red") +  
  geom_line(aes(y = FOR_pred, group = County.x), color = "red") +  
  labs(title = "Firearm Ownership Rate for Four Selected Counties",
       x = "Year",
       y = "Firearm Ownership Rate",
       color = "County") +
  theme_minimal() +
  scale_color_manual(values = rainbow(4))

