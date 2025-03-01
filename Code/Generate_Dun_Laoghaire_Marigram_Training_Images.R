# ==========================================
# Title: Dún Laoghaire Tidal Data Analysis
# Author: Patrick McLoughlin
# Date: January 2025
# Description: 
#   This script loads tidal data for Dún Laoghaire in 1925 from a local CSV file,
#   processes it, performs harmonic analysis, generates tidal predictions,
#   and produces weekly marigrams (tidal graphs).
# ==========================================

# ==========================================
# 1. Load Required Packages
# ==========================================
library('tidyverse')    
library('lubridate')    
library('TideHarmonics') 
library('reshape2')
library('zoo')          
library('wesanderson')
library('VulnToolkit')

# ==========================================
# 2. Clear Workspace and Graphics
# ==========================================
graphics.off()
rm(list=ls())

# ==========================================
# 3. Load and Format Dún Laoghaire Data
# ==========================================
# **USER INSTRUCTION**: The data file '1925_DL_m_ODM.csv' should be located in the 'Data_Training' folder.
# Ensure that the file '1925_DL_m_ODM.csv' is available in the "Excel_Data/Dún_Laoghaire" subfolder on GitHub, or 
# place it in the appropriate directory relative to your working directory.

# Example folder structure:
#  Project Folder/
#  ├── Data_Training/
#  │   └── 1925_DL_m_ODM.csv  # <-- Your data file here

# **USER INSTRUCTION**: Modify the 'file_path' below to point to the correct location of the file.
# For example:
file_path <- "path/to/your/folder/1925_DL_m_ODM.csv"  # Update to the correct path

# Check if the file exists at the specified path
if (!file.exists(file_path)) {
  stop("The data file could not be found at the specified path: ", file_path, 
       "\nPlease make sure the file is in the correct location.")
}

# Load the data
dun_laoghaire <- read_csv(file_path, col_names = c("DateTime", "Water_Level"), skip = 1) %>%
  mutate(DateTime = as.POSIXct(DateTime, format="%Y-%m-%dT%H:%M:%SZ", tz='UTC'),
         Water_Level = as.numeric(Water_Level)) %>%
  select(DateTime, Water_Level)

# ==========================================
# 4. Perform Tidal Harmonic Analysis
# ==========================================
ftide_calc_dl <- ftide(dun_laoghaire$Water_Level, dun_laoghaire$DateTime, hc60, smsl = FALSE, nodal = FALSE)

# ==========================================
# 5. Generate Tidal Predictions
# ==========================================
t1 <- as.POSIXct("1925-01-01 00:00", tz = "UTC")
t2 <- as.POSIXct("1926-01-01 00:00", tz = "UTC")
pred_tide <- predict(ftide_calc_dl, t1, t2, by = 1/60)
ptide <- tibble(DateTime = seq(t1, t2, by = "min"), PredTide = pred_tide)

# ==========================================
# 6. Add Astronomical Tide to Data (With Smoothing)
# ==========================================
dun_laoghaire <- dun_laoghaire %>%
  mutate(AstroTide = spline(x = ptide$DateTime, y = ptide$PredTide, method = 'fmm', xout = DateTime)$y)

# ==========================================
# 7. Extract High and Low Tides
# ==========================================
hl <- HL(dun_laoghaire$AstroTide, dun_laoghaire$DateTime)

# ==========================================
# 8. Create and Save Marigrams for Each Week in 1925
# ==========================================
dun_laoghaire <- dun_laoghaire %>% 
  mutate(Week = week(DateTime), DOY = yday(DateTime), Hour = hour(DateTime), Minute = minute(DateTime))

# ==========================================
# 9. Loop through each week in 1925 and create/save marigrams
# ==========================================
# **USER INSTRUCTION**: Set the working directory where you want to save results
# **USER INSTRUCTION**: Modify the file path below if you want to save it to a different directory
setwd("path/to/your/directory")  # Modify this to your desired folder location

for (wk in 1:52) {
    weekly_data <- dun_laoghaire %>% filter(Week == wk)

    if (nrow(weekly_data) == 0) {
        message("Skipping Week ", wk, ": No data available")
        next
    }

    if (all(is.na(weekly_data$AstroTide))) {
        message("Skipping Astro Tide Marigram for Week ", wk, ": Data contains only NA values")
    } else {
        p_astro_tide <- create_marigram(weekly_data, "AstroTide", paste("Astro Tide Marigram for Week", wk))
        if (!is.null(p_astro_tide)) {
            ggsave(paste0("week_", wk, "_1925_astro_tide.png"), plot = p_astro_tide, width = 10, height = 6)
        }
    }
}

# ==========================================
# End of Script
# ==========================================

# Ensure we have hourly intervals for the year 1925
t1 <- as.POSIXct("1925-01-01 00:00", tz = "UTC")
t2 <- as.POSIXct("1926-01-01 00:00", tz = "UTC")

# Generate a sequence of hourly intervals for the entire year
hourly_intervals <- tibble(
    DateTime = seq(t1, t2, by = "hour")
)

# Merge the hourly intervals with the existing tidal data (assuming dun_laoghaire already has a DateTime and AstroTide column)
hourly_data <- hourly_intervals %>%
    left_join(dun_laoghaire, by = "DateTime") %>%
    select(DateTime, AstroTide)

# Save to CSV of predicted Benchmark tidal data
output_file_path <- "path/to/your/folder//Predict_Hourly_Tide_Data_1925.csv"  # Relative path
write_csv(hourly_data, output_file_path) 

message("Hourly tidal data for the year 1925 has been saved to 'Predict_Hourly_Tide_Data_1925.csv'")
