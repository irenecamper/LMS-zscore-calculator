library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)

source("compute_zscores.R")
source("create_plot.R")

# Read data
dxa_path <- "/Volumes/auditing-groupdirs/SUN-CBMR-HOLBAEK/database freeze/2023_March/DXA-scans_ALL/dexa_sub.v.03.2023.xlsx"

# Rename and recode dxa data for make it ready for compute_zscores_file() function
dxa_data <- readxl::read_excel(dxa_path, col_names = TRUE) %>%
  dplyr::rename(
    PATID = pat_ID,
    percent_FM = fat_percent,
    gender = dexa_gender,
    age = dexa_age
  ) %>%
  dplyr::mutate(
    gender = dplyr::case_when(
      gender == 1 ~ 0,  # male (1) --> 0 
      gender == 2 ~ 1,  # male (2) --> 1
    )
  ) %>%
  dplyr::select(PATID, percent_FM, gender, age)

# Compute zscores
dxa_data_new = compute_zscores_file(data = dxa_data)

# Generate plot
plot <- create_plot(age_group = "children", value = "percent_FM", gender = 0)
plot
