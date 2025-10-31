# =============================================================================
# Waist–Hip Data Preparation Script
#
# Purpose:
#   Load, clean, and prepare population-based and hospital-based anthropometric
#   datasets for z-score computation (e.g., waist, hip, height measures).
#
# Inputs:
#   1. Population-based reference data:
#        - visit_measures_Kontrolbørn.v.03.2023.xlsx
#        - basis_data_Kontrolbørn.v.03.2023.xlsx
#        These files must include: pat_ID, visit_date, birth_date, gender, height, waist, hip
#
#   2. Hospital-based data:
#        - visit_measures_Enhedsbørn.v.03.2023.xlsx
#        - basis_data_Enhedsbørn.v.03.2023.xlsx
#        These files must include: pat_ID, visit_date, birth_date, gender, height, waist, hip
#
# Outputs:
#   - pop_data: cleaned population-based reference dataset with derived ratios
#   - hospital_data: cleaned hospital-based dataset with derived ratios
# =============================================================================

# --- Setup -------------------------------------------------------------------
library(readxl)
library(dplyr)

pop_data_path <- "/Volumes/auditing-groupdirs/SUN-CBMR-HOLBAEK/database freeze/2023_March/Population_based/visit_measures_Kontrolbørn.v.03.2023.xlsx"
pop_basis_data_path <- "/Volumes/auditing-groupdirs/SUN-CBMR-HOLBAEK/database freeze/2023_March/Population_based/basis_data_Kontrolbørn.v.03.2023.xlsx"
# example_path  <- "example_file.xlsx"  # Replace with actual HOLBAEK data path
hospital_data_path <- "/Volumes/auditing-groupdirs/SUN-CBMR-HOLBAEK/database freeze/2023_March/Hospital_based/visit_measures_Enhedsbørn.v.03.2023.xlsx"
hospital_basis_data_path <- "/Volumes/auditing-groupdirs/SUN-CBMR-HOLBAEK/database freeze/2023_March/Hospital_based/basis_data_Enhedsbørn.v.03.2023.xlsx"

# --- Load and prepare reference data -----------------------------------------

pop_basis_data <- readxl::read_excel(pop_basis_data_path) |>
  dplyr::select(birth_date, gender, pat_ID)

pop_data <- readxl::read_excel(pop_data_path) |>
  dplyr::left_join(pop_basis_data, by = "pat_ID") |>
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
# example_data <- readxl::read_excel(example_path) |>
  # dplyr::select(age, gender, waist, hip, height) |>
  # dplyr::mutate(
    # waist_hip_ratio = ifelse(hip > 0, waist / hip, NA_real_),
    # waist_height_ratio = ifelse(height > 0, waist / height, NA_real_) 
  # )


hospital_basis_data <- readxl::read_excel(hospital_basis_data_path) |>
  dplyr::select(birth_date, gender, pat_ID)

hospital_data <- readxl::read_excel(hospital_data_path) |>
  dplyr::left_join(hospital_basis_data, by = "pat_ID") |>
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
  dplyr::select(PATID, age, gender, height, waist, hip, waist_hip_ratio, waist_height_ratio) |>
  dplyr::filter(!is.na(age) & is.finite(age))
