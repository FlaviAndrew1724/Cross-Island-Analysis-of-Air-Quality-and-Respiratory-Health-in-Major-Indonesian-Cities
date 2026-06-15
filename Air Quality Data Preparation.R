#Packages
install.packages("rlang")
install.packages("openxlsx")

library(dplyr)
library(readxl)
library(ggplot2)
library(tidyverse)
library(lubridate)
library(openxlsx)

health_data <- read_excel("C:/Users/ASUS/Downloads/health_dataset.xlsx")
air_data <- read_excel("C:/Users/ASUS/Downloads/air_quality_dataset_daily.xlsx")

# 2. Clean, Impute, and Aggregate to the Island-Month level
final_island_air_quality <- air_data %>%
  # Parse the Date and create a Month_Year column (YYYY-MM format)
  mutate(Date = ymd(Date),
         Month_Year = format(Date, "%Y-%m")) %>%
  
  # Clean numeric columns: replace commas with periods and convert to numeric
  mutate(across(c(TN, TX, TAVG, SS), ~as.numeric(str_replace_all(as.character(.), ",", ".")))) %>%
  
  # Group Cities into Islands based on your custom mapping
  mutate(Island = case_when(
    City %in% c("Central Jakarta", "North Jakarta", "Sleman", "Bandung", "Bogor", "Cirebon", 
                "Semarang", "Cilacap", "Surabaya", "Malang", "Tangerang", "Denpasar") ~ "Java",
    
    City %in% c("Ambon", "Ternate", "Jayapura", "Sorong", "Mataram", "Kupang") ~ "Papua",
    
    City %in% c("Medan", "Padang", "Palembang", "Pangkal Pinang", 
                "Tanjung Pinang", "Batam") ~ "Sumatra",
    
    City %in% c("Banjarbaru", "Banjarmasin", "Tarakan") ~ "Kalimantan",
    
    City %in% c("Manado", "Makassar") ~ "Sulawesi",
    
    TRUE ~ "Other/Unassigned" 
  )) %>%
  
  # DEALING WITH MISSING VALUES (NAs) BEFORE AGGREGATING
  # Impute missing days with the city's monthly average so missing days don't skew the island average
  group_by(City, Month_Year) %>%
  mutate(across(c(TN, TX, TAVG, SS), ~ifelse(is.na(.), mean(., na.rm = TRUE), .))) %>%
  ungroup() %>%
  
  # FINAL STEP: Aggregate up to the Island and Month level
  group_by(Island, Month_Year) %>%
  summarise(
    TN = mean(TN, na.rm = TRUE),
    TX = mean(TX, na.rm = TRUE),
    TAVG = mean(TAVG, na.rm = TRUE),
    SS = mean(SS, na.rm = TRUE),
    .groups = "drop" # Drops the grouping structure after summarizing
  ) %>%
  
  # Sort chronologically by Island and then Month for a clean output
  arrange(Island, Month_Year)

# 3. View the first few rows of the final aggregated dataset
head(final_island_air_quality, 10)

write.xlsx(
  final_island_air_quality,
  "C:/Users/ASUS/Downloads/final_island_air_quality.xlsx",
  overwrite = TRUE
)



