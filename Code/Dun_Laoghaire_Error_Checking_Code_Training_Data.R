# Title: Dún Laoghaire Tidal Data Analysis
# Author: Patrick McLoughlin
# Date: January 2025
# Description: 
#   This script loads predicted tidal data for Dún Laoghaire in 1925 from a local CSV file.
#   It also loads digitized tidal data from a student-produced Excel file.
#   The script then compares observed vs. predicted tides, calculates residuals, and 
#   generates visualizations along with a summary text file.
#   Both `Predict_Hourly_Tide_Data_1925.csv` and `Week_51_DL.xlsx` can be found in the GitHub folder: 
#   Excel_Data/Dún_Laoghaire/Training_Data/

# ==========================================

setwd("C:/path/to/your/folder")  # <-- MODIFY THIS PATH TO YOUR OWN DIRECTORY

library(readr)  # For reading CSV files
library(readxl) # For reading Excel files
library(dplyr)
library(ggplot2)
predicted_data <- read_csv("Predict_Hourly_Tide_Data_1925.csv")
# Check available sheets
excel_sheets("Week_51_DL.xlsx")
# Read the first sheet (modify sheet name if needed)
digitized_data <- read_excel("Week_51_DL.xlsx", sheet = 1)
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
       x = "DateTime", y = "Tide Height (m)",
       color = "Legend") +
  theme_minimal()

# Create a summary
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

# Save to a text file
output_file <- "Residuals_Summary.txt"
writeLines(summary_text, output_file)

cat("Residuals summary saved at:", output_file)

