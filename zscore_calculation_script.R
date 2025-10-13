# --- Load libraries ------------------------------------------------------------
library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)

# --- Load external functions ---------------------------------------------------
source("compute_zscores.R")
source("create_plot.R")

# --- Define input & output paths -----------------------------------------------
dxa_path <- "/Volumes/auditing-groupdirs/SUN-CBMR-HOLBAEK/database freeze/2023_March/DXA-scans_ALL/dexa_sub.v.03.2023.xlsx"
# dxa_zscores_path <- "write_folder_path_here/dxa_data_zscores.csv")

# --- Load and prepare DXA data -------------------------------------------------
dxa_data <- readxl::read_excel(dxa_path, col_names = TRUE) %>%
  ## Rename variables --> `new_column_name = old_column_name`
  dplyr::rename(
    PATID      = pat_ID,
    percent_FM = fat_percent,
    gender     = dexa_gender,
    age        = dexa_age,
    FM         = `Total Fedtmasse`,
    height     = `dexa_height`,
    weight     = `dexa_weight`,
    LM         = `Total Fedtfri masse`,
    LM_arm     = `Arme Fedtfri masse`,
    LM_leg     = `Ben Fedtfri masse`,
    FM_arm     = `Arme Fedtmasse`,
    FM_leg     = `Ben Fedtmasse`,
    FM_trunk   = `Truncus diff Fedtmasse`
  ) %>%
  ## Recode gender
  dplyr::mutate(
    gender = dplyr::case_when(
      gender == 1 ~ 0,  # male (1) --> 0 
      gender == 2 ~ 1,  # male (2) --> 1
      TRUE ~ NA_real_
    )
  ) %>%
  ## Compute derived body composition variables
  dplyr::mutate(
    FMI                    = FM / (height^2),
    FM_trunk_quotient_limb = FM_trunk / (FM_arm + FM_leg),
    LMI                    = LM / (height^2),
    appendicular_LMI       = (LM_arm + LM_leg) / (height^2),
    BMI                    = weight / (height^2),
    # fitted_FMI             = FM / (height^x_fm),
    # fitted_LMI             = LM / (height^x_lm),
    # fitted_ALMI            = (LM_arm + LM_leg) / (height^x_alm),
    # fitted_BMI             = weight / (height^x_bmi)
  ) %>%
  ## Keep only relevant columns for z-score computation
  dplyr::select(
    PATID,
    percent_FM,
    FM_trunk_quotient_limb,
    LMI,
    appendicular_LMI,
    # fitted_FMI,
    # fitted_BMI,
    # fitted_ALMI,
    # fitted_LMI,
    gender,
    age,
    weight,
    height
  )

# --- Compute zscores -----------------------------------------------------------
# dxa_data_new will contain the original columns `value` + the corresponding `zscore-value` columns
dxa_data_new = compute_zscores_file(data = dxa_data)

# --- Save dxa zscores data -----------------------------------------------------
# write.csv(dxa_data_new, dxa_zscores_path, row.names = FALSE)

# --- optional : Visualize reference percentile curves --------------------------
# Example usage
# plot <- create_plot(
#   ref_data_path = "data/",
#   age_group = "children",
#   value = "percent_FM",
#   gender = 0
# )
# print(plot)

# --- optional : Test the compute_zscores_function with example file -----------
# your_filename = "example_file.xlsx"
# compute_zscores_file(filename = your_filename)