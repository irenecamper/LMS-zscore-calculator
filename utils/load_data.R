# =============================================================================
# Waist–Hip Data Preparation Script
#
# Purpose:
#   Load and prepare waist and hip data for z-score computation.
#
# Inputs:
#   1. Reference dataset (CSV) — e.g., "Insulin_data_pop.csv" — containing:
#        PATID, age, gender, waist, hip, height
#   2. Example or HOLBAEK dataset (Excel) containing:
#        age, gender, waist, hip
#
# Outputs:
#   - ref_data: cleaned reference dataset with derived WHR
#   - example_data: cleaned example dataset with derived WHR
# =============================================================================

# --- Setup -------------------------------------------------------------------
library(readxl)
library(dplyr)

ref_data_path <- "/Volumes/auditing-groupdirs/SUN-CBMR-HOLBAEK/data analysis/data_tools/Frithioff-Boejsoe_2019/Insulin_data_pop.csv"
example_path  <- "example_file.xlsx"  # Replace with actual HOLBAEK data path

# --- Load and prepare reference data -----------------------------------------
ref_data <- utils::read.csv2(ref_data_path, as.is = TRUE, na.strings = c("", "NA")) |>
  dplyr::mutate(
    age = as.numeric(difftime(as.Date(visit_date, format = "%Y-%m-%d"),
                              as.Date(birth_date, format = "%Y-%m-%d"),
                              units = "days")) / 365.25
  ) |>
  dplyr::rename(
    PATID = pat_ID                   # Unique participant ID
  ) |>
  dplyr::mutate(
    gender = case_when(              # Recode gender: male = 0, female = 1
      gender == 1 ~ 0,
      gender == 2 ~ 1,
      TRUE ~ NA_real_
    ),
    waist_hip_ratio = ifelse(hip > 0, waist / hip, NA_real_),
    waist_height_ratio = ifelse(height > 0, waist / height, NA_real_)
  ) |>
  dplyr::select(PATID, age, gender, height, waist, hip, waist_hip_ratio, waist_height_ratio)

# --- Load and prepare example data -------------------------------------------
example_data <- readxl::read_excel(example_path) |>
  dplyr::select(age, gender, waist, hip, height) |>
  dplyr::mutate(
    waist_hip_ratio = ifelse(hip > 0, waist / hip, NA_real_),
    waist_height_ratio = ifelse(height > 0, waist / height, NA_real_) 
  )
