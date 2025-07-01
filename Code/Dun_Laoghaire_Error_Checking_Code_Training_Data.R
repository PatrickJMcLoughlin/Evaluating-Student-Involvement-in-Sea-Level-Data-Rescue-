# Title: Dún Laoghaire Tidal Data Analysis
# Author: Patrick McLoughlin
# Date: January 2025
# Description: 
#   This script loads predicted tidal data for Dún Laoghaire in 1925 from a local CSV file.
#   It also loads digitized tidal data from a student-produced Excel file.
#   The script then compares observed vs. predicted tides, calculates residuals, and 
#   generates visualizations along with a summary text file.
# ==========================================
library(readr)  # For reading CSV files
library(readxl) # For reading Excel files
library(dplyr)
library(ggplot2)

# Set working directory (modify if needed)
# setwd("C:/path/to/your/folder")

# Check if the required files exist
if (!file.exists("Excel_Data/Predict_Hourly_Tide_Data_1925.csv")) {
  stop("File 'Predict_Hourly_Tide_Data_1925.csv' not found in the 'Excel_Data' subfolder. Please check the README for instructions.")
}

if (!file.exists("Excel_Data/Week_51_DL.xlsx")) {
  stop("File 'Week_51_DL.xlsx' not found in the 'Excel_Data' subfolder. Please check the README for instructions.")
}

# Load predicted tidal data from the Excel_Data subfolder
# (The file 'Predict_Hourly_Tide_Data_1925.csv' should be in the 'Excel_Data' subfolder)
predicted_data <- read_csv("Excel_Data/Predict_Hourly_Tide_Data_1925.csv")

# Check available sheets of digitized data
excel_sheets("Excel_Data/Week_51_DL.xlsx")  # Sample data found in the 'Excel_Data' subfolder on GitHub

# Read the first sheet (modify sheet name if needed)
digitized_data <- read_excel("Excel_Data/Week_51_DL.xlsx", sheet = 1)

# View first few rows of both datasets for verification
head(predicted_data)
head(digitized_data)

# Convert DateTime to POSIXct for merging
predicted_data <- predicted_data %>%
  mutate(DateTime = as.POSIXct(DateTime, format="%Y-%m-%d %H:%M:%S", tz="UTC"))

digitized_data <- digitized_data %>%
  mutate(DateTime = as.POSIXct(Datetime, format="%Y-%m-%d %H:%M:%S", tz="UTC"))

# Merge predicted and digitized data on DateTime
merged_data <- inner_join(predicted_data, digitized_data, by = "DateTime") %>%
  select(DateTime, AstroTide, Height) %>%
  rename(Predicted = AstroTide, Observed = Height)

# Compute residuals
merged_data <- merged_data %>%
  mutate(Residuals = Observed - Predicted)

# Plot predicted vs. observed tide levels and residuals
ggplot(merged_data, aes(x = DateTime)) +
  # Predicted line, thicker and dashed for visibility
  geom_line(aes(y = Predicted, color = "Predicted"), linewidth = 1.5, linetype = "dashed") +
  # Observed line (solid)
  geom_line(aes(y = Observed, color = "Observed"), linewidth = 1) +
  # Points for observed (digitized) data
  geom_point(aes(y = Observed, color = "Observed"), size = 2) +
  # Residuals line (blue)
  geom_line(aes(y = Residuals, color = "Residuals"), linewidth = 1, linetype = "solid") +
  # Adding a horizontal line at y = 0 for reference (residual = 0)
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  # Define color scheme for the plot
  scale_color_manual(values = c("Predicted" = "blue", "Observed" = "black", "Residuals" = "green")) +
  # Labels and theme
  labs(title = "Predicted vs Observed Tides and Residuals",
       x = "DateTime", y = "Tide Height (ft)",
       color = "Legend") +
  theme_minimal()

# Create a summary of residuals
summary_text <- paste0("Summary of Residuals:\n",
                       "Total observations: ", nrow(merged_data), "\n",
                       "Mean Residual: ", round(mean(merged_data$Residuals, na.rm = TRUE), 3), "\n",
                       "Median Residual: ", round(median(merged_data$Residuals, na.rm = TRUE), 3), "\n",
                       "Max Residual: ", round(max(merged_data$Residuals, na.rm = TRUE), 3), "\n",
                       "Min Residual: ", round(min(merged_data$Residuals, na.rm = TRUE), 3), "\n\n",
                       "Top 5 Largest Residuals:\n")

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
