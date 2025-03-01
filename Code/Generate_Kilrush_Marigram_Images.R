 # ================================
# Title: Kilrush Tidal Data Analysis
# Author: [Patrick McLoughlin]
# Date: [November 2024]
# Description: 
#   This script fetches tidal data from the Irish National Tide Gauge Network, 
#   processes it, performs harmonic analysis, generates tidal predictions, 
#   and produces weekly marigrams (tidal graphs) for Kilrush, Ireland in 2021.
#   
#   Users can modify `year(DateTime) == 2021` in the filtering step to generate 
#   marigrams for other years (e.g., 2019 or 2020).
# ================================

# ================================
# 1. Load Required Packages
# ================================
library('rerddap')      # Access ERDDAP server for MI data
library('tidyverse')    # Process data neatly
library('lubridate')    # Handle dates
library('TideHarmonics') # A nice but flawed tidal package!
library('reshape2')
library('zoo')
library('wesanderson')
library('VulnToolkit')

# ================================
# 2. Clear Workspace and Graphics
# ================================
graphics.off()
rm(list=ls())

# ================================
# 3. Set Up Data Source
# ================================
url <- "https://erddap.marine.ie/erddap/" # Link to MI's ERDDAP server
cache_delete_all(force = FALSE)          # Clear ERDDAP cache if needed

# ================================
# 4. Load and Format Kilrush Data
# ================================
kilrush <- tabledap('IrishNationalTideGaugeNetwork', 'station_id=%22Kilrush%20Lough%22', url = url) %>%
  mutate(DateTime = as.POSIXct(time, format="%Y-%m-%dT%H:%M:%SZ", tz='UTC'),
         Water_Level_OD_Malin = as.numeric(Water_Level_OD_Malin)) %>%
  select(DateTime, Water_Level_OD_Malin, station_id)

# ================================
# 5. Extract 2021 Data
# ================================
# Change the year(DateTime) == 2021 condition to the desired year(s) for data extraction.
# For example, to generate data for 2020, change it to year(DateTime) == 2020.
# Similarly, for 2019 data, change it to year(DateTime) == 2019.

kilrush_2021 <- filter(kilrush, year(DateTime) == 2021)

# ================================
# 6. Perform Tidal Harmonic Analysis
# ================================
ftide_calc_kilrush <- ftide(kilrush_2021$Water_Level_OD_Malin, 
                            kilrush_2021$DateTime, hc60, smsl = FALSE, nodal = FALSE)

# ================================
# 7. Generate Tidal Predictions
# ================================
t1 <- as.POSIXct("2021-01-01 00:00", tz = "UTC")
t2 <- as.POSIXct("2022-01-01 00:00", tz = "UTC")
pred_tide <- predict(ftide_calc_kilrush, t1, t2, by = 1/60)
ptide <- tibble(DateTime = seq(t1, t2, by = "min"), PredTide = pred_tide)

# ================================
# 8. Add Astronomical Tide to Kilrush Data
# ================================
kilrush_2021 <- kilrush_2021 %>%
  mutate(AstroTide = spline(x = ptide$DateTime, y = ptide$PredTide, method = 'fmm', xout = DateTime)$y)

# ================================
# 9. Extract High and Low Tides
# ================================
hl <- HL(kilrush_2021$AstroTide, kilrush_2021$DateTime)

# ================================
# 10. Visualize and Save Tidal Data for June 2021
# ================================
ggplot(kilrush_2021 %>% filter(month(DateTime) == 6)) +
  geom_line(aes(x = DateTime, y = Water_Level_OD_Malin)) +
  geom_line(data = ptide, aes(x = DateTime, y = PredTide), color = 'pink', linetype = 'dashed') +
  geom_point(data = hl, aes(x = time, y = level), color = 'purple') +
  labs(title = "Kilrush - June 2021 with Predicted Tide and High/Low Points")

# ================================
# 11. Create and Save Marigrams for Each Week in 2021
# ================================
# Prepare the kilrush_2021 data with additional time-based columns
kilrush_2021 <- kilrush_2021 %>%
  mutate(Week = week(DateTime), DOY = yday(DateTime), Hour = hour(DateTime), Minute = minute(DateTime))

# ================================
# Set working directory to save the marigrams
# ================================
# **USER INSTRUCTION**: 
# Change the working directory path below to the folder on your local machine where you want to save the marigrams.
# 
# Example:
# On Windows, you might use:
# setwd("C:/Users/yourname/Desktop/TideMarigrams")
# 
# On macOS or Linux, you could use:
# setwd("/Users/yourname/Desktop/TideMarigrams")

setwd("C:/path/to/your/folder")  # <-- MODIFY THIS PATH TO YOUR OWN DIRECTORY

# ================================
# Create a function to generate marigrams
# ================================
create_marigram <- function(weekly_data, tide_column, title) {
  ggplot(weekly_data) +
    geom_line(aes(x = Hour + Minute / 60, y = !!sym(tide_column), group = DOY, color = as.factor(format(DateTime, "%b %d")))) +
    geom_text(aes(x = min(Hour + Minute / 60), y = 2, label = format(min(DateTime), "%b %d")), hjust = 'left', color = 'red') +
    geom_text(aes(x = max(Hour + Minute / 60), y = 2, label = format(max(DateTime), "%b %d")), hjust = 'right', color = 'red') +
    theme_bw() +
    labs(color = "Date", title = title) +
    scale_color_brewer(palette = "Set1") +
    theme(legend.position = "right")
}

# ================================
# Loop through each week in 2021 and save the marigrams
# ================================
for (wk in 1:52) {
  weekly_data <- kilrush_2021 %>% filter(Week == wk)
  
  # Check if there is data for the current week
  if (nrow(weekly_data) > 0) {
    # Create Astro Tide marigram
    p_astro_tide <- create_marigram(weekly_data, "AstroTide", paste("Astro Tide Marigram for Week", wk))
    ggsave(paste0("week_", wk, "_2021_astro_tide.png"), plot = p_astro_tide)
    
    # Create Water Level marigram (OPTIONAL: not used in student assignment, but generated in code)
    # These marigrams are for reference or extra analysis if desired.
    p_water_level <- create_marigram(weekly_data, "Water_Level_OD_Malin", paste("Water Level Marigram for Week", wk))
    ggsave(paste0("week_", wk, "_2021_water_level.png"), plot = p_water_level)
  }
}

# ================================
# End of Script
# ================================

