PROJECT TITLE
Evaluating Student Involvement in Sea Level Data Rescue
________________________________________
REPOSITORY DESCRIPTION
This repository supports the GY369 Oceanography module at Maynooth University (2024-2025, Phase 1) and the GY310B Geography Research Workshops (Phase 2). The project focuses on digitizing tidal images (marigrams) for Kilrush and Dún Laoghaire. The code in this repository generates marigrams for both locations using tidal harmonic analysis.
It also provides tools to process student-digitized tidal data, correcting it against predicted tidal points for Kilrush and Dún Laoghaire (training datasets), and comparing the data to accurately digitized historical records for Dún Laoghaire (McLoughlin et al., 2024). 
Note: Historical images use feet (Chart Datum) rather than metres (ODM - Ordnance Datum Malin), which is used in all other scripts. Historical images to be digitized can be accessed in McLoughlin et al. (2024) at [https://doi.pangaea.de/10.1594/PANGAEA.967078?format=html#download], under 'Level_0_Raw_Images' for the year 1925. For days omitted from the digitized/adjusted data (McLoughlin et al., 2024), comparisons with the published data may be more challenging. It is preferable to use marigrams with full weeks of digitized data for more reliable comparisons when digitizing.

This repository accompanies the research article "Evaluating Student Involvement in Sea Level Data Rescue" and includes the following components:
________________________________________
R CODE SCRIPTS
The repository contains R scripts for the following main tasks:
1. Error-checking Digitized Marigrams
Scripts to validate digitized marigrams for Kilrush and Dún Laoghaire by identifying discrepancies in high and low tidal points (Kilrush) and hourly intervals (Dún Laoghaire). The scripts help assess digitization accuracy.
2. Connecting to the Marine Institute's ERDDAP Server
Scripts for generating marigrams for Kilrush covering the years 2019 to 2021.
________________________________________
NOTES
There may be discrepancies between the Dún Laoghaire 1925 data and student-digitized data. This is because the 1925 data comes from McLoughlin et al., 2024 (Level_2_Adjusted_Data), which has been corrected for bends and skews in the original images. A 20-30mm offset allowance is acceptable. However, all tidal points at hourly intervals should align closely, and any missing points will be identified.
________________________________________
PURPOSE OF CODE
This code serves multiple purposes:
•Training Tool for Students: The code generates tidal images for Kilrush and Dún Laoghaire, helping students develop and assess their skills in digitizing complex tidal graphs (marigrams).
•Validation of Student Data: It validates student-digitized data for Dún Laoghaire against historical data (McLoughlin et al., 2024), a crucial step before students transition to digitizing real historical tidal images.
•Citizen Science Training: This code also serves as a tool for training potential citizen scientists in the digitization of historical tidal data. The principles applied here could be adapted to citizen science projects focused on digitizing fluvial data (hydrographs), which share similar complexities with tidal graphs.
________________________________________
FOLDER STRUCTURE
• Code:
Contains scripts for generating and validating marigrams.
• Excel_Data:
Contains sample student-digitized Excel files for Kilrush and Dún Laoghaire, including the 1925 Dún Laoghaire data (McLoughlin et al., 2024) and predicted tidal data, all formatted for use in R. Please review this folders contents to fully understand the data, especially if you plan to use the code.
________________________________________
TABLE OF CONTENTS
1. Code
2. Excel_Data
PROJECT TITLE.txt
________________________________________
CONTACT
For questions, please contact:
Email: patrick.mcloughlin.2014@mumaile.ie
