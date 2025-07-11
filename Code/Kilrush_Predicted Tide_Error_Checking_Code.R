# Kilrush Tidal Data Analysis and Validation
# Author: Patrick McLoughlin
# Date: November 2024
# Description: 
# This R script corrects digitized marigrams for Kilrush, using sample data from the "Excel_Data" folder.
# It generates the required ftide model for error checking against both predicted and digitized tidal data.
# The script provides an accurate comparison by matching residuals (differences) between predicted and actual data.
# When run correctly, it generates a text file summary of the residuals, offering insights into the accuracy of the digitized marigrams.
# The script defaults to 2021, but users can modify `year(DateTime) == 2021` to analyze other years (e.g., 2019 or 2020).
# NOTE: In the 2020 data, PredHeight (pink points) appears not only at the correct times, 
#       but also throughout the days in the plot at different times due to an issue in the data. 
#       However, this discrepancy does not affect the residuals (purple points), 
#       which are clearly represented in the plot and accurately reflected in the text file output.

# ============================================
# Required Libraries Installation
# ============================================
# These libraries are needed to access and process data.
library('rerddap')     # Access ERDAPP server for Marine Institute data
library('tidyverse')   # Data processing and visualization
library('lubridate')   # Date handling
library('TideHarmonics') # Tidal harmonic analysis
library('reshape2')    # Data reshaping
library('zoo')         # Time series handling
library('wesanderson') # Color palettes for plots
library('VulnToolkit') # Vulnerability toolkit
library(readxl)
library(dplyr)
library(lubridate)
library(ggplot2)
# ============================================
# Clear Previous Session (Graphics & Workspace)
# ============================================
# This section clears the previous R session's graphics and workspace.
graphics.off()  # Clears previous plots
rm(list=ls())   # Removes all objects from the environment

# ============================================
# Setting up ERDDAP Server URL
# ============================================
# Access Marine Institute ERDDAP server for retrieving data.
url <- "https://erddap.marine.ie/erddap/"
cache_delete_all(force = FALSE)  # Clears cached queries for fresh data retrieval

# ============================================
# Retrieving & Formatting Kilrush Station Data
# ============================================
# Download tide gauge data for the Kilrush station from the ERDDAP server
kilrush <- tabledap('IrishNationalTideGaugeNetwork',
                   'station_id=%22Kilrush%20Lough%22',
                   url = url) %>%
  mutate(DateTime = as.POSIXct(time, format="%Y-%m-%dT%H:%M:%SZ", tz='UTC'),
         Water_Level_OD_Malin = as.numeric(Water_Level_OD_Malin)) %>%
  select(DateTime, Water_Level_OD_Malin, station_id)

# ============================================
# Visualizing Tidal Data for Kilrush
# ============================================
# Plot water levels for June 2021 and the entire year 2021
ggplot(kilrush %>% filter(year(DateTime) == 2021, month(DateTime) == 6)) +
  geom_line(aes(x = DateTime, y = Water_Level_OD_Malin)) +
  labs(title = "Kilrush - June 2021")

ggplot(kilrush %>% filter(year(DateTime) == 2021)) +
  geom_line(aes(x = DateTime, y = Water_Level_OD_Malin)) +
  labs(title = "Kilrush - 2021")

# ============================================
# Tidal Harmonics Calculation for 2021
# ============================================
# Extracting data for 2021 and calculating fitted tides using harmonic analysis
kilrush_2021 <- filter(kilrush, year(DateTime) == 2021)
ftide_calc_kilrush <- ftide(kilrush_2021$Water_Level_OD_Malin, kilrush_2021$DateTime, hc60, smsl = FALSE, nodal = FALSE)

# Save the calculated tide model for future use
save(ftide_calc_kilrush, file = "C:/path/to/your/folder/ftide_calc_kilrush.Rdata")

# ============================================
# Predicting Tides for 2021
# ============================================
# Predicting tides at 1-minute intervals from Jan 2021 to Jan 2022
t1 <- as.POSIXct("2021-01-01 00:00", tz = "UTC")
t2 <- as.POSIXct("2022-01-01 00:00", tz = "UTC")
pred_tide <- predict(ftide_calc_kilrush, t1, t2, by = 1/60)

# Create a tibble for predicted tides
ptide <- tibble(DateTime = seq(t1, t2, by = "min"),
                PredTide = pred_tide)

# Add the predicted astronomical tides to the Kilrush dataset
kilrush_2021 <- kilrush_2021 %>%
  mutate(AstroTide = spline(x = ptide$DateTime,
                            y = ptide$PredTide,
                            method = 'fmm',
                            xout = DateTime)$y)

# Extract high and low tides from the predicted data
hl <- HL(kilrush_2021$AstroTide, kilrush_2021$DateTime)

# ============================================
# Plotting Actual vs Predicted Tides
# ============================================
# Plot actual vs predicted tides for June 2021
ggplot(kilrush_2021 %>% filter(month(DateTime) == 6)) +
  geom_line(aes(x = DateTime, y = Water_Level_OD_Malin)) +
  geom_line(data = ptide, aes(x = DateTime, y = PredTide), color = 'pink', linetype = 'dashed') +
  geom_point(data = hl, aes(x = time, y = level), color = 'purple') +
  labs(title = "Kilrush - Actual vs Predicted Tides (June 2021)")

# ============================================
# Generate Marigrams
# ============================================
# Generate marigram for a week of data (Week 22)
kilrush_2021 <- kilrush_2021 %>% mutate(Week = week(DateTime), DOY = yday(DateTime), Hour = hour(DateTime), Minute = minute(DateTime))
wk <- 22

# Plot water levels for a week
ggplot(kilrush_2021 %>% filter(Week == wk)) +
  geom_line(aes(x = Hour + Minute/60, y = Water_Level_OD_Malin, group = DOY)) + 
  geom_text(aes(x = min(Hour + Minute/60), y = 2, label = min(DateTime)), hjust = 'left', color = 'red') +
  geom_text(aes(x = max(Hour + Minute/60), y = 2, label = max(DateTime)), hjust = 'right', color = 'red') +
  theme_bw()

# Save the marigram plot
ggsave(paste0("kilrush_2021_week_", wk, ".png"))

# ============================================
# Loading External Data (High/Low Tides)
# ============================================
# Load the "High and Low Tides" dataset for further analysis
# Set working directory (modify if needed)
setwd("C:/path/to/your/folder")
file <- "High_and_Low_Tides_Week14-17_Kilrush.xlsx"  # Sample data found in the 'Excel_Data' subfolder on GitHub
data <- read_xlsx(file, skip = 8)

# Remove unwanted rows and adjust column names
data <- data %>%
  filter(!is.na(`High or Low`)) %>%
  filter(`High or Low` != "High or Low")

colnames(data) <- c("High or Low", "Datetime", "Hour", "Height", "Range", "Interval", "Date")

# Convert Datetime to POSIXct
data$Datetime <- as.POSIXct(data$Datetime, origin = "2021-01-01", tz = "UTC")

# ============================================
# Comparing Predicted vs Actual High-Low Tides
# ============================================
# Compare predicted high/low tides with actual data
hl <- HL(kilrush_2021$AstroTide, kilrush_2021$DateTime)
data$PredHeight <- data$`Height` + NA
for (k in 1:length(data$PredHeight)) {
  ind <- which.min(abs(data$Datetime[k] - hl$time))
  data$PredHeight[k] <- hl$level[ind] 
}

data$Residual <- data$`Height` - data$PredHeight
data$Interval <- c(as.numeric(diff(data$Datetime)) / 60, NA)


# Plot actual vs predicted heights
ggplot(data) +
  geom_line(aes(x=Datetime, y=`Height`)) + 
  geom_point(aes(x=Datetime, y=`Height`)) +
  geom_point(data=hl,aes(x=time, y=level ), color='pink')+
  geom_point(aes(x=Datetime, y=`Height` - PredHeight),color = 'purple')+
  lims(x = c(as.POSIXct(min(date(data$Datetime), na.rm = TRUE), tz = "UTC"), 
             as.POSIXct(max(date(data$Datetime)+1, na.rm = TRUE), tz = "UTC")))

# Assume 'data' contains the dataset including 'Residual' and other columns.
# Create a 'Week' column to group the data by week
data <- data %>%
  mutate(Week = week(Datetime)) # Week of the year

# Function to summarize data for each week
get_weekly_residual_summary <- function(week_num, output = FALSE) {
  week_data <- data %>%
    filter(Week == week_num) # Filter data for the specified week
  
  # Count the number of high and low tides
  num_highs <- nrow(week_data %>% filter(`High or Low` == "h"))
  num_lows <- nrow(week_data %>% filter(`High or Low` == "l"))
  
  # Get the top 5 largest residuals
  top_residuals <- week_data %>%
    arrange(desc(abs(Residual))) %>%
    select(`High or Low`, Datetime, Hour, Height, Range, Interval, Date, PredHeight, Residual) %>%
    head(5)
  
  # Print the summary
  summary_text <- paste0("\nWeek: ", week_num, "\n",
                          "Number of highs: ", num_highs, "\n",
                          "Number of lows: ", num_lows, "\n\n",
                          "5 largest residuals:\n")
  
  # Add top residuals to the summary
  summary_text <- paste0(summary_text, capture.output(print(top_residuals)), collapse = "\n")
  
  # Output to console or file
  if (output) {
    return(summary_text)
  } else {
    cat(summary_text)
  }
}

# Loop through the unique weeks in the data and generate the summary for each week
unique_weeks <- unique(data$Week)

# Example of changing the output path to a different folder
output_file <- "C:/path/to/your/folder/kilrush_weekly_residuals_summary.txt"


# Check if the output directory exists
if (!dir.exists(dirname(output_file))) {
  dir.create(dirname(output_file), recursive = TRUE)
}

# Start writing to the output file
sink(output_file)  # Redirect the output to a file
for (wk in unique_weeks) {
  summary_output <- get_weekly_residual_summary(wk, output = TRUE)
  cat(summary_output)
}
sink()  # Stop redirection

cat("Residuals summary saved at:", output_file)
