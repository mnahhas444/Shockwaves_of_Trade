library(readxl)
library(dplyr)
library(tidyr)
library(openxlsx)
library(priceR)

china_trade <- read_excel("Documents/Master's Thesis/Thesis/china_trade.xlsx")

country <- china_trade$CTYNAME
inflation_dataframe <- retrieve_inflation_data(country)
countries_dataframe <- show_countries()

adjust_for_inflation(china_trade$IYR, 1990, country, to_date = 2022,
                     inflation_dataframe = inflation_dataframe,
                     countries_dataframe = countries_dataframe)

adj_prices <- adjust_for_inflation(china_trade$IYR, 1990, country, to_date = 2022,
                                   inflation_dataframe = inflation_dataframe,
                                   countries_dataframe = countries_dataframe)

adjusted_prices_df <- data.frame(year = seq(1990, 2022), adjusted_price = adj_prices)

write.xlsx(adjusted_prices_df, file = "~/Documents/Master's Thesis/Thesis/adj_trade.xlsx")

#merging to calculate exposure variable

df<- read_excel("Documents/Master's Thesis/Thesis/COMPACTED_DATA.xlsx")

adj_trade <- read_excel("Documents/Master's Thesis/Thesis/adj_trade.xlsx")

merged_data <- merge(df, adj_trade, by = c("Year"), all = TRUE)

write.xlsx(merged_data, file = "~/Documents/Master's Thesis/Thesis/compact2.xlsx")


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


