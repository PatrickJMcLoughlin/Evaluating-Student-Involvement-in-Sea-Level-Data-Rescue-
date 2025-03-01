# Title: Dún Laoghaire Tidal Data Analysis (Historic image QC)
# Author: Patrick McLoughlin
# Date: January 2025
# Description: 
#   This script loads the 1925 tidal data (McLoughlin et al., 2024) for Dún Laoghaire from a CSV file.
#   It also loads digitized tidal data from a student-produced Excel file (in this case in feet relative to chart Datum).
#   The script then compares the 1925 published digitized tidal data with the student digitized data, calculates residuals,
#   and generates visualizations along with a summary text file.

# Load required libraries
library(readr)      # For reading CSV files
library(readxl)     # For reading Excel files
library(dplyr)      # For data manipulation
library(ggplot2)    # For visualization
library(lubridate)  # For handling date-time formats

# Set working directory (modify if needed)
# setwd("C:/path/to/your/folder")  # <-- MODIFY THIS PATH TO YOUR OWN DIRECTORY

# Check if the required files exist
if (!file.exists("Excel_Data/Dún_Laoghaire/1925_DL.csv")) {
  stop("File '1925_DL.csv' not found. Please check the README for instructions.")
}

if (!file.exists("21-28th_September_1925.xlsx")) {
  stop("File '21-28th_September_1925.xlsx' not found. Please check the README for instructions.")
}

# Load 1925 tidal data from McLoughlin et al., 2024  
# (Formatted 1925 data available in the "Excel_Data/Dún_Laoghaire" subfolder on GitHub)  
data <- read_csv("Excel_Data/Dún_Laoghaire/1925_DL.csv")

# Rename columns to standardized names and convert DateTime to POSIXct format
data <- data %>%
  rename(DateTime = `Date/ Time`, Data = `Reading (ft)`) %>%
  mutate(DateTime = as.POSIXct(DateTime, format = "%Y-%m-%d %H:%M:%S", tz = "UTC"))

# Load digitized tide data
digitized_data <- read_excel("21-28th_September_1925.xlsx", sheet = 1) # Sample data found in the 'Excel_Data' subfolder on GitHub

# Convert Datetime to POSIXct format and keep only necessary columns
digitized_data <- digitized_data %>%
  mutate(DateTime = ymd_hms(Datetime, tz = "UTC")) %>%
  select(DateTime, Observed = Height)

# Merge the data and observed data based on DateTime
merged_data <- inner_join(data, digitized_data, by = "DateTime")

# Compute residuals (Observed - Data)
merged_data <- merged_data %>%
  mutate(Residuals = Observed - Data)

# Plot observed vs. data tide levels and residuals
ggplot(merged_data, aes(x = DateTime)) +
  geom_line(aes(y = Data, color = "Data"), linewidth = 1.5, linetype = "dashed") +
  geom_line(aes(y = Observed, color = "Observed"), linewidth = 1) +
  geom_point(aes(y = Observed, color = "Observed"), size = 2) +
  geom_line(aes(y = Residuals, color = "Residuals"), linewidth = 1, linetype = "solid") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  scale_color_manual(values = c("Data" = "blue", "Observed" = "black", "Residuals" = "green")) +
  labs(title = "Data vs Observed Tides and Residuals",
       x = "DateTime", y = "Tide Height (m)",
       color = "Legend") +
  theme_minimal()

# Create a summary of residuals
summary_text <- paste0(
  "Summary of Residuals:\n",
  "Total observations: ", nrow(merged_data), "\n",
  "Mean Residual: ", round(mean(merged_data$Residuals, na.rm = TRUE), 3), "\n",
  "Median Residual: ", round(median(merged_data$Residuals, na.rm = TRUE), 3), "\n",
  "Max Residual: ", round(max(merged_data$Residuals, na.rm = TRUE), 3), "\n",
  "Min Residual: ", round(min(merged_data$Residuals, na.rm = TRUE), 3), "\n\n",
  "Top 5 Largest Residuals:\n"
)

# Get top 5 largest absolute residuals
top_residuals <- merged_data %>%
  arrange(desc(abs(Residuals))) %>%
  head(5)

# Append residual data to summary text
summary_text <- paste0(summary_text, capture.output(print(top_residuals)), collapse = "\n")

# Save summary to a text file
output_file <- "Residuals_Summary.txt"
writeLines(summary_text, output_file)

cat("Residuals summary saved at:", output_file)
