# Cross-Island Analysis of Air Quality and Respiratory Health in Major Indonesian Cities

**Team:** Angela 林佩璇 (111302055) · Bryan 陳福益 (111ZU1034) · Owen 傅宥景 (112703010) · Andrew 李育強 (112ZU1026)

---

## Overview

Indonesia's unique geography spans highly urbanized zones and dense forested areas across thousands of islands. This project investigates how climate and air quality conditions relate to respiratory disease outcomes — specifically pneumonia and pulmonary tuberculosis — across five major islands: Java, Sumatra, Kalimantan, Sulawesi, and Papua. The goal is to determine whether regional environmental differences are significant enough to demand island-specific public health responses rather than a uniform national policy.

---

## Repository Structure

```
├── code/
│   └── Final Project.R             # Code for analysis
├── data preparation/
│   └── Air_Quality_Data_Preparation.R   # Data cleaning and aggregation script
├── analysis/
│   └── Air_Quality_Health_Analysis.pdf  # Full analysis report and visualizations
├── poster/
│   └── Poster_big_data.png              # Academic poster presentation
└── README.md
```

---

## Data

**Source:** [BMKG DataOnline](https://dataonline.bmkg.go.id/dataonline-home) (Badan Meteorologi, Klimatologi, dan Geofisika)

Daily meteorological observations from 29 cities across Indonesia, covering July 2024 to May 2026 (~20,000 records).

| Column | Description |
|--------|-------------|
| Province | Indonesian province |
| City | Observation city |
| Date | Date of observation |
| TN | Minimum daily temperature (°C) |
| TX | Maximum daily temperature (°C) |
| TAVG | Average daily temperature (°C) |
| SS | Sunshine duration (hours) |

**Island groupings used in this project:**

| Island | Cities |
|--------|--------|
| Java | Central Jakarta, North Jakarta, Sleman, Bandung, Bogor, Cirebon, Semarang, Cilacap, Surabaya, Malang, Tangerang, Denpasar |
| Sumatra | Medan, Padang, Palembang, Pangkal Pinang, Tanjung Pinang, Batam |
| Kalimantan | Banjarbaru, Banjarmasin, Tarakan |
| Sulawesi | Manado, Makassar |
| Papua | Ambon, Ternate, Jayapura, Sorong, Mataram, Kupang |

---

## How to Run

Install the required R packages:

```r
install.packages(c("dplyr", "readxl", "ggplot2", "tidyverse", "lubridate"))
```

Open `Air_Quality_Data_Preparation.R` and update the file paths to match your local setup:

```r
health_data <- read_excel("your/path/to/Health Dataset.xlsx")
air_data    <- read_excel("your/path/to/FINAL_DATASET_.xlsx")
```

The script will:
1. Parse dates and create a Month_Year column
2. Clean numeric columns (convert comma-decimal format to standard numeric)
3. Map each city to its island group
4. Impute missing daily values using each city's monthly average
5. Aggregate to island-month level means for TN, TX, TAVG, and SS

Output: a dataframe `final_island_air_quality` ready for analysis.

---

## Analyses

Full results and visualizations are in `Air_Quality_Health_Analysis.pdf`. The project covers four main analyses:

**1. Island-Specific Correlation Matrices**
Pearson correlation heatmaps for each island, showing how temperature, humidity, and sunshine duration relate to pneumonia and TB case counts. Results varied considerably across islands, indicating that the climate-disease relationship is not uniform nationwide.

**2. Spatio-Temporal Seasonal Trend Analysis**
Line charts from mid-2024 to mid-2025 show that each island has a distinct seasonal disease peak driven by its own local weather cycle. Disease curves shift chronologically across the archipelago rather than peaking at the same time — a key finding that supports island-specific health planning.

**3. Comparative Variance Analysis (ANOVA)**
One-way ANOVA confirmed that baseline respiratory disease burden is statistically unequal across islands. Java carries a disproportionately high absolute burden compared to islands like Kalimantan, which makes equal national resource distribution an ineffective strategy.

**4. Island-Stratified Predictive Modeling
The primary purpose of the island-stratified predictive model is to mathematically evaluate whether climatic variations—specifically average temperature (TAVG)—can serve as a reliable indicator for forecasting pneumonia case counts across different regions. By utilizing a Poisson regression framework tailored for count data, the model separates the fixed baseline healthcare burdens of each island (represented by the vertical gaps between the regression lines) from the actual environmental impact (represented by the slopes). This stratification reveals that environmental sensitivity is highly localized; for instance, while a drop in temperature is a strong predictor for rising pneumonia cases in Java, the remaining islands display a flat temperature "inelasticity," indicating that their disease transmission dynamics are driven by factors entirely independent of average temperature within this climate bracket. Ultimately, this allows public health officials to identify which regional populations are climatically vulnerable, proving that localized infrastructure and geographic baselines matter far more for resource allocation than uniform weather patterns.

**5. PCA Clustering of Island Environmental-Health Profiles**
PCA compressed all environmental and health variables into two dimensions (Dim1 explains 85.5% of variance). Java sits entirely isolated on the biplot, confirming that its urban density creates a health-climate profile unlike any other island. Sulawesi and Papua cluster closer together, reflecting shared coastal characteristics.

---

## Key Findings

- Java's disease burden is statistically and visually distinct from all other islands due to high population density and urbanization.
- Each island has its own seasonal disease peak, which shifts chronologically across the year as weather patterns move through the archipelago.
- The drivers of respiratory disease differ between islands — a single national model cannot capture this variation.
- Findings support dynamic, localized allocation of health resources rather than a uniform national approach.
