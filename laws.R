library(readxl)
library(dplyr)
library(tidyr)
library(openxlsx)

df <- read_excel("Documents/Master's Thesis/Thesis/Laws.xlsx")

df$rank <- ifelse(df$Number >= 0 & df$Number <= 15, 1,
                  ifelse(df$Number >= 16 & df$Number <= 29, 2,
                         ifelse(df$Number >= 30 & df$Number <= 60, 3,
                                ifelse(df$Number >= 61 & df$Number <= 80, 4, 5))))



write.xlsx(df, file = "Documents/Master's Thesis/Thesis/law_rank.xlsx")