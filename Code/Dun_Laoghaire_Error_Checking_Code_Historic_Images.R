# Title: Dún Laoghaire Tidal Data Analysis (Historic image QC)
# Author: Patrick McLoughlin
# Date: January 2025
# Description: 
#   This script loads the 1925 tidal data (McLoughlin et al., 2024) for Dún Laoghaire from a CSV file.
#   It also loads digitized tidal data from a student-produced Excel file (in this case in feet relative to chart Datum).
#   The script then compares the 1925 published digitized tidal data with the student digitized data, calculates residuals,
#   and generates visualizations along with a summary text file.
#   Both `1925_DL.csv` and `21-28th_September_1925.xlsx` can be found in the GitHub folder: 
#   Excel_Data/Dún_Laoghaire/Historic_Data/

# Load required libraries
library(readr)    # For reading CSV files
library(readxl)   # For reading Excel files
library(dplyr)    # For data manipulation
library(ggplot2)  # For visualization
library(lubridate) # For handling date-time formats

# Set working directory (modify if needed)
setwd("C:/path/to/your/folder")  # <-- MODIFY THIS PATH TO YOUR OWN DIRECTORY

# Load reference tide data
reference_data <- read_csv("1925_DL.csv")

# Rename columns to standardized names
reference_data <- reference_data %>%
  rename(DateTime = `Date/ Time`, Reference = `Reading (ft)`) %>%
  mutate(DateTime = as.POSIXct(DateTime, format="%Y-%m-%d %H:%M:%S", tz="UTC"))

# Load digitized tide data
digitized_data <- read_excel("21-28th_Sept_Test_1925.xlsx", sheet = 1)

# Convert Datetime to POSIXct format (handling ISO format)
digitized_data <- digitized_data %>%
  mutate(DateTime = ymd_hms(Datetime, tz="UTC")) %>%
  select(DateTime, Observed = Height)  # Keep only necessary columns

# Merge reference and observed data
merged_data <- inner_join(reference_data, digitized_data, by = "DateTime")

# Compute residuals
merged_data <- merged_data %>%
  mutate(Residuals = Observed - Reference)

# Plot observed vs reference tide levels and residuals
ggplot(merged_data, aes(x = DateTime)) +
  geom_line(aes(y = Reference, color = "Reference"), linewidth = 1.5, linetype = "dashed") +
  geom_line(aes(y = Observed, color = "Observed"), linewidth = 1) +
  geom_point(aes(y = Observed, color = "Observed"), size = 2) +
  geom_line(aes(y = Residuals, color = "Residuals"), linewidth = 1, linetype = "solid") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  scale_color_manual(values = c("Reference" = "blue", "Observed" = "black", "Residuals" = "green")) +
  labs(title = "Reference vs Observed Tides and Residuals",
       x = "DateTime", y = "Tide Height (ft)",
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
