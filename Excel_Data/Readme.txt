Excel Folder Contents:

This folder contains sample digitized data for Kilrush and Dún Laoghaire, compiled in Excel worksheet format by students as part of this research. The data represents a sample of student work only.

-Kilrush Folder:
• High_and_Low_Tides_Week14-17_Kilrush.xlsx: A sample week of student-digitized data.

Dún Laoghaire Folder:
The Dún Laoghaire folder contains two subfolders: Training_Data and Historic_Data.
-Training_Data Subfolder:
• Week_51_DL.xlsx: Contains a sample week of student-digitized training data.
• 1925_DL_m_ODM.csv: Contains 1925 tidal data downloaded from McLoughlin et al., 2024a (https://doi.pangaea.de/10.1594/PANGAEA.967078?format=html#download), adjusted to ODM by subtracting 2.1886 (the difference between Dún Laoghaire Datum 2.722m and 0.5334m, or 1.75ft) (see McLoughlin et al., 2024b) (https://rmets.onlinelibrary.wiley.com/doi/10.1002/gdj3.256). This CSV file is used to create predicted tidal images for the Dún Laoghaire training dataset.
• Predict_Hourly_Tide_Data_1925.csv: Contains the predicted tidal data for Dún Laoghaire, generated using the predicted/training tidal data. This is used to benchmark against student training data for error checking.

-Historic_Data Subfolder:
• 1925_DL.csv: Contains the tidal data for 1925, derived from the 1925_DL dataset, formatted for use in R (McLoughlin et al., 2024a).
• 21-28th_September_1925.xlsx: A sample week of student digitized data on the historic data.

Please note that the historic data is in feet relative to chart datum, whereas the Kilrush and Dún Laoghaire training data is in metres relative to Ordnance Datum Malin (ODM).

Additional Note:
The historical images to be digitized can be accessed in McLoughlin et al. (2024) at [https://doi.pangaea.de/10.1594/PANGAEA.967078?format=html#download], under "Level_0_Raw_Images" for the year 1925.  For days omitted from the digitized/adjusted data (McLoughlin et al., 2024), comparisons with the published data may be more challenging. It is preferable to use marigrams with full weeks of digitized data for more reliable comparisons when digitizing.
