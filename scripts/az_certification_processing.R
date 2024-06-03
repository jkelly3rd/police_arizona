# Import required libraries
library(tidyverse)
library(lubridate)
library(readxl)
library(janitor)

# Clear the workspace to avoid conflicts with existing variables
rm(list = ls())

# Define the root directory and the output directory
root_dir = getwd()
output_dir = "data/processed/"

# Define the paths to the input Excel files
employment_file = "data/source/006_PR_2023_0413_AllOfficers_w_AppointmentsAndFinalActions.xlsx"

# Define the paths to the output CSV files
az_index = "data/processed/az-2023-index.csv"
az_original_employment = "data/processed/az-2023-original-employment.csv"

# Create a template dataframe for the officers index. This will be used to ensure that the final dataframe has the correct structure.
template_index <- data.frame("person_nbr" = character(0),
                             "full_name" = character(0),
                             "first_name" = character(0),
                             "middle_name" = character(0),
                             "last_name" = character(0),
                             "suffix" = character(0),
                             "year_of_birth" = numeric(0),
                             "age" = numeric(0),
                             "agency" = character(0),
                             "type" = character(0),
                             "rank" = character(0),
                             "start_date" = as.Date(character(0)),
                             "end_date" = as.Date(character(0))
)

# Import the Excel files, converting date columns with hard NULL values to NA. Also convert SC's placeholder for null (1/1/1111) to NA.
# The janitor::clean_names() function is used to clean up the column names.
az_history <- read_excel(employment_file, 
                         col_types = c("text", "text", "text","date","date","text","text","text",
                                       "date", "text", "text", "text")) %>% janitor::clean_names()
# name columns for consistency
colnames(az_history) <- c("person_nbr","full_name","agency","start_date","end_date","rank",
                          "current_certificate_status","last_action","date_last_action","case_numbers",
                          "final_actions","final_action_dates")

# output the original employment data
write_csv(az_history, az_original_employment)


# drop columns 8-12 that are not needed for the officer index for AZ
az_history <- az_history %>% select(-c("last_action","date_last_action","case_numbers","final_actions","final_action_dates"))

# Change the full_name to title case
az_history$full_name <- str_to_title(az_history$full_name)
# Get the last name from everything prior to the first comma
az_history$last_name <- gsub(",.*", "", az_history$full_name)
# Get the rest_name from everything after the first ", "
az_history$rest_name <- gsub(".*, ", "", az_history$full_name)

split_names <- strsplit(az_history$rest_name, " ")

# Assign the corresponding elements from the split name to new columns
az_history$first_name <- sapply(split_names, '[', 1)
az_history$middle_name <- sapply(split_names, '[', 2)
az_history$suffix <- sapply(split_names, '[', 3)

# If suffix is not NA and is not equal to "Jr","II" or "III" then append it to the existing middle_name column and delete it from the suffix column
az_history$middle_name <- ifelse(is.na(az_history$suffix), az_history$middle_name, paste(az_history$middle_name, az_history$suffix, sep = " "))
az_history$suffix <- ifelse(az_history$suffix %in% c("Jr","II","III"), az_history$suffix, NA)

# If there is " Jr" in the last name column, remove it from the last name column and append it to the suffix column
az_history$suffix <- ifelse(grepl(" Jr", az_history$last_name), "Jr", az_history$suffix)
az_history$last_name <- gsub(" Jr", "", az_history$last_name)
# If there is a Jr in the middle name, remove it from the middle name column and append it to the suffix column, ignoring case
az_history$suffix <- ifelse(grepl("Jr", az_history$middle_name, ignore.case = TRUE), "Jr", az_history$suffix)
az_history$middle_name <- gsub("Jr", "", az_history$middle_name, ignore.case = TRUE)
# Fix oddly formatted names individually
az_history$first_name[az_history$person_nbr == 15416] <- "Santiago"
az_history$middle_name[az_history$person_nbr == 15416] <- NA
az_history$last_name[az_history$person_nbr == 15416] <- "Renteria"
az_history$suffix[az_history$person_nbr == 15416] <- "Jr"

# If there is " Ii" or " Iii" in the last name column, remove it from the last name column and append it to the suffix column
az_history$suffix <- ifelse(grepl(" Iii", az_history$last_name), "III", az_history$suffix)
az_history$last_name <- gsub(" Iii", "", az_history$last_name)
az_history$suffix <- ifelse(grepl(" Ii", az_history$last_name), "II", az_history$suffix)
az_history$last_name <- gsub(" Ii", "", az_history$last_name)

# Reassemble the full name from first_name, middle_name, last_name, and suffix
az_history$full_name <- paste(az_history$first_name, ifelse(is.na(az_history$middle_name),"",az_history$middle_name), az_history$last_name, ifelse(is.na(az_history$suffix),"",az_history$suffix), sep = " ")
# Use squish to remove extra spaces
az_history$full_name <- str_squish(az_history$full_name)
# Drop rest_name
az_history <- az_history %>% select(-rest_name)

# Now merge the cleaned South Carolina data into the index template
az_officers_index <- bind_rows(template_index,az_history)

# Export csv for project
az_officers_index %>% write_csv(az_index)












