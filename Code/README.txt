This folder contains R scripts for analyzing, error-checking, and generating tidal marigrams for Kilrush (Phase 1) and Dún Laoghaire (Phase 2A/B) using predicted and historical data sources. The scripts utilize harmonic analysis, ERDDAP data retrieval, and residual analysis for quality control.
This folder includes R scripts for three main tasks:
1. Error-checking the digitized marigrams for both Kilrush and Dún Laoghaire Harbour.
2. Connecting to the Marine Institute's ERDDAP server to generate marigrams for Kilrush for the years 2019 to 2021.
3. Producing tidal predictions and weekly marigrams for Dún Laoghaire (1925) using harmonic analysis and historical data.
 
Overview of Code:
- Generate_Kilrush_Marigram_Images (R file)
This R script generates marigrams (tidal graphs) for Kilrush, Ireland, for a specified year by retrieving tidal data from the Irish National Tide Gauge Network via the ERDDAP server. The script performs the following key tasks:
1. Data Retrieval & Processing
•Fetches water level data from the ERDDAP server, referenced in metres to Ordnance Datum Malin (ODM).
•Converts timestamps and formats data for analysis.
•Extracts tidal data for a specific year (default: 2021).
2. Tidal Analysis & Prediction
•Uses harmonic analysis to compute predicted tides.
•Generates tidal predictions at minute intervals.
•Identifies high and low tide points.
3. Marigram Generation & Visualization
•Creates weekly tidal graphs with color-coded traces based on date.
•Overlays predicted tides and observed water levels.
•Saves marigrams in PNG format, named according to the week number (e.g., week_49_2021_astro_tide.png).
4. Customization & Configuration
•Users can modify year(DateTime) == 2021 in the filtering step to generate marigrams for other years (e.g., 2019 or 2020).
•The script allows setting a custom working directory for saving output files.
5. Usage in Student Assignments
•The Astro Tide data is used for student exercises.
•The Water Level data is also processed but not required for assignments (though available for additional analysis).

- Kilrush_Predicted_Tide_Error_Checking_Code (R file):
This R script validates and corrects digitized marigrams for Kilrush, using sample data stored in the "Excel_Data" folder. It generates the necessary ftide model for error checking by comparing predicted and digitized tidal data. The script performs the following key functions:
1. Data Retrieval & Processing
• Loads tidal data from the ERDDAP server.
• Reads and processes digitized marigram data from Excel files.
• Converts timestamps and formats data for analysis.
2. Tidal Harmonic Analysis & Prediction
• Uses TideHarmonics to generate predicted tidal levels.
• Compares predicted tides against digitized (actual) data.
• Identifies high and low tide points.
3. Error Checking & Residual Analysis
• Computes residuals (differences between predicted and digitized tidal heights).
• Summarizes discrepancies by week.
• Generates a text file (kilrush_weekly_residuals_summary.txt) with error statistics.
4. Customization & Year Selection
• The script defaults to 2021, but users can modify year(DateTime) == 2021 to analyse other years (e.g., 2019 or 2020).
• Ensures that the digitized data corresponds to the selected year for accurate validation.
5. Output & Visualization
• Produces plots comparing actual vs. predicted tidal levels.
• Highlights key discrepancies for manual review.
• Saves weekly residual summaries for further analysis.
This script is essential for validating the accuracy of digitized marigrams and ensuring consistency between predicted and recorded tidal data.
### Note on 2020 Data Issue  
For the year 2020, there is an issue where the pink points (PredHeight)—which represent the predicted tide heights—appear not only for the highs and lows but also at different times of the day in the plot.
However: 
- This does not interfere with the purple residuals, which correctly plot only for the actual and predicted values. 
- The generated text file correctly includes only the residuals between the actual and predicted tidal points. 
- This issue does not affect the overall analysis or the residuals between actual and predicted tides but should be noted when visualizing/interpreting the 2020  plots.

- Generate_Dun_Laoghaire_Marigram_Training_Images (R Script):
This R script generates predicted tidal marigrams (tidal graphs) for Dún Laoghaire using the TideHarmonics package and 1925 tidal data (source: McLoughlin et al., 2024). The script follows these steps:
1. Data Loading & Preprocessing
• Reads tidal height data from a CSV file (with format modified for readability), referenced in metres to Ordnance Datum Malin (ODM). Please find the Excel files in the relevant subfolder within the Excel_Data folder.
• Converts timestamps to POSIXct format.
• Ensures tidal heights are referenced to metres Ordnance Datum Malin (ODM).
2. Tidal Harmonic Analysis & Prediction
• Performs harmonic analysis on the 1925 tidal dataset.
• Uses the computed model to predict tides at minute-level resolution.
3. Visualization: Weekly Marigrams
• Generates weekly tidal marigrams for 1925.
• Highlights high and low tide points.
• Saves marigram plots as PNG files.
4. Error Handling & Grid Adjustments
• Ensures proper grid alignment in plots.
• Skips weeks with missing or incomplete data.
5. Saving Hourly Tide Predictions
• Extracts hourly interval tide predictions for 1925.
• Saves the processed data as a CSV file for the 1925 predicted tidal data at hourly intervals, for error checking purposes if required.
Customization:
• The script defaults to 1925, but users can adjust t1 and t2 for different years.
• Output files are stored in a user-defined directory (update setwd()).
This script is useful for historical tide reconstruction, machine learning training datasets, and comparative tidal analysis.

- Dun_Laoghaire_Error_Checking_Code_Training_Data:
This R script performs error analysis on the 1925 predicted tide data for Dún Laoghaire by:
• Reading predicted tidal data from a CSV file. Please find the Excel files in the relevant subfolder within the Excel_Data folder.
• Importing student-digitized marigram data from an Excel file.
• Visualizing both datasets for comparison.
• Calculating residuals (differences between predicted and observed tides).
• Generating a summary text file with residual statistics for error analysis.
________________________________________
- Dun_Laoghaire_Error_Checking_Code_Historic_Images:
This R script performs quality control on the 1925 digitized tidal data (McLoughlin et al., 2024) for Dún Laoghaire by:
• Reads the 1925 published digitized tidal data from a CSV file (with format modified for readability), referenced in feet relative to Chart Datum (CD).
• Loading student-digitized marigram data from an Excel file. Please find the Excel files in the relevant subfolder within the Excel_Data folder.
• Visualizing both datasets for comparison.
• Calculating residuals (differences between predicted and observed tides).
• Generating a summary text file with residual statistics.
• Identifying any missing or incorrectly digitized points.
Since the 1925 data is based on Level_2_Adjusted data (which corrects for skews and offsets in the image), a slight offset is expected between the student-digitized data and the 1925 dataset. However, if the student data is digitized correctly, it should align within 20-30 mm (0.02-0.03 m) of the 1925 data. Note: Not all marigrams were fully digitized; in some cases, poor trace quality prevented complete digitization.


