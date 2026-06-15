#Packages
library(dplyr)
library(readxl)
library(ggplot2)
library(tidyverse)
library(lubridate)

install.packages(c("dplyr", "readr", "ggplot2", "lubridate", "ggcorrplot", "MASS", "FactoMineR", "factoextra", "tidyr"))


air_quality <- read_excel("C:/Users/ASUS/Downloads/final_island_air_quality.xlsx")
health_data <- read_excel("C:/Users/ASUS/Downloads/health_dataset.xlsx")

# Create Island variable and standardize month format
health_data <- health_data %>%
  mutate(
    Island = case_when(
      City == "DKI Jakarta" ~ "Java",
      City == "Medan" ~ "Sumatra",
      City == "Samarinda" ~ "Kalimantan",
      City == "Makassar" ~ "Sulawesi",
      City == "Jayapura" ~ "Papua"
    ),
    Month_Year = format(as.Date(paste0("01/", Month), format = "%d/%m/%Y"),
                        "%Y-%m")
  )

df_merged <- inner_join(health_data, air_quality, by = c("Island", "Month_Year"))

#1. Island-Specific Correlation Matrices

library(ggplot2)
library(ggcorrplot)
library(tidyr)

# Select relevant columns for correlation
corr_vars <- c("Pneumonia Cases", "Pulmonary Tuberculosis", "TAVG", "SS")

# Loop through each island to generate and print a correlation plot
islands <- unique(df_merged$Island)

for(isl in islands) {
  island_data <- df_merged %>% 
    filter(Island == isl) %>% 
    select(all_of(corr_vars)) %>%
    mutate(across(everything(), as.numeric))
  
  corr_matrix <- cor(island_data, use = "complete.obs", method = "spearman")
  
  p <- ggcorrplot(corr_matrix, 
                  hc.order = TRUE, 
                  type = "lower",
                  lab = TRUE, 
                  title = paste("Correlation Matrix for", isl),
                  colors = c("blue", "white", "red"))
    print(p)
  }
  

#2. Spatio-Temporal Seasonal Trend Analysis

df_merged <- df_merged %>%
  mutate(Date = my(Month))

ggplot(df_merged, aes(x = Date, y = `Pneumonia Cases`, color = Island)) +
  geom_line(linewidth = 1) +
  geom_point() +
  facet_wrap(~ Island, scales = "free_y") + 
  labs(title = "Seasonal Trend of Pneumonia Cases Across Indonesian Islands",
       x = "Date",
       y = "Number of Pneumonia Cases",
       color = "Island") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))





#3. Baseline Inequalities: Comparative Variance Analysis (ANOVA)

anova_model <- aov(`Pneumonia Cases` ~ Island, data = df_merged)
summary(anova_model)


ggplot(df_merged, aes(x = reorder(Island, -`Pneumonia Cases`), y = `Pneumonia Cases`, fill = Island)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "Distribution of Pneumonia Cases by Island",
       subtitle = "Assessing baseline geographic inequalities",
       x = "Island",
       y = "Pneumonia Cases") +
  theme_minimal() +
  theme(legend.position = "none")



#4.Island-Stratified Predictive Modeling

library(MASS)
library(dplyr)

glm_model <- glm(`Pneumonia Cases` ~ TAVG * Island, 
                 family = poisson(link = "log"), 
                 data = df_merged)

summary(glm_model)


ggplot(df_merged, aes(x = TAVG, y = `Pneumonia Cases`, color = Island)) +
  
  # 1. Add the raw data points as a scatter plot
  geom_point(alpha = 0.6, size = 2.5) +
  
  # 2. Fit and draw the Poisson Regression lines for each island separately
  geom_smooth(method = "glm", 
              method.args = list(family = "poisson"), 
              se = FALSE,       
              linewidth = 1.2) +
  
  # 3. Add descriptive titles and labels for the axes
  labs(title = "Island-Stratified Predictive Model",
       subtitle = "Effect of Avaerage Temperature on Pneumonia Cases (Poisson Regression)",
       x = "Avaerage Temperature (TAVG %)",
       y = "Predicted Pneumonia Cases",
       color = "Island") +
  
  # 4. Apply a clean visual theme and distinct colors
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "right",
    panel.grid.minor = element_blank()
  ) +
  scale_color_brewer(palette = "Set1") # Uses a distinct, colorblind-friendly palette



#5. PCA Clustering of Island Environmental-Health Profiles
library(dplyr)
library(FactoMineR)
library(factoextra)

# 1. Aggregate data by City to find the mean of all numeric variables
df_agg <- df_merged %>%
  group_by(City, Island) %>%
  summarise(across(where(is.numeric), mean, na.rm = TRUE), .groups = "drop")

# 2. Extract just the numeric data for PCA 
# THE FIX: Added 'dplyr::' before select to override the MASS package
pca_data <- df_agg %>% dplyr::select(-City, -Island)
rownames(pca_data) <- df_agg$City  # Set city names as row names for the plot

# 3. Run PCA (scale.unit = TRUE standardizes variables with different scales)
pca_res <- PCA(pca_data, scale.unit = TRUE, graph = FALSE)

# 4. Visualize the PCA Biplot
fviz_pca_biplot(pca_res, 
                repel = TRUE, # Avoid text overlapping
                col.ind = df_agg$Island, # Color dots by Island
                palette = "jco", 
                addEllipses = FALSE,
                label = "all",
                title = "PCA Biplot: Environmental-Health Profiling of Indonesian Islands",
                legend.title = "Island")




