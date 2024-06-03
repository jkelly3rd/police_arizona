# Arizona Officer History Data Processing

This script processes data obtained from the state of Arizona that includes personnel information and employment history for all officers certified in the state. It performs several operations to clean, standardize, and reformat the data. The original data is preserved in a csv format for reference, and a standardized index is created for further analysis.

## R Packages Used

- tidyverse: For data manipulation and visualization
- lubridate: For handling date-time data
- readxl: For reading Excel files
- janitor: For cleaning data and managing the workspace

## Data Files

The input data is an Excel file named `006_PR_2023_0413_AllOfficers_w_AppointmentsAndFinalActions.xlsx` located in the `data/source/` directory. The file contains employment history data for officers in Arizona.

## Data Cleaning

The data cleaning process involves several steps:

- Importing the Excel file and cleaning up the column names for consistency with the index files created for other states in the project.
- Splitting the full name into first name, middle name, last name, and suffix. Cleaning up the suffixes. Reassembling the full name.

## Output

The cleaned data is written to two CSV files: `az-2023-index.csv` and `az-2023-original-employment.csv`. The index file contains a simplified version of the data for easy reference, while the original employment file contains the full cleaned data.

## Questions or suggestions for improvement?

Processing by John Kelly, CBS News at JohnL.Kelly@cbsnews.com.

