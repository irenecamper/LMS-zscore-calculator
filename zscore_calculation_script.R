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
  # Rename variables --> `new_column_name = old_column_name`
  dplyr::rename(
    PATID      = pat_ID, ## PATID
    percent_FM = fat_percent, ## % fat mass (%)
    gender     = dexa_gender, ## gender : male (1) or female (2)
    age        = dexa_age, ## age (years)
    FM         = `Total Fedtmasse`, ## total fat mass (kg)
    height     = `dexa_height`, ## height (cm)
    weight     = `dexa_weight`, ## weight (kg)
    LM         = `Total Fedtfri masse`, ## total lean mass (kg)
    LM_arm     = `Arme Fedtfri masse`, ## arm lean mass (kg)
    LM_leg     = `Ben Fedtfri masse`, ## leg lean mass (kg)
    FM_arm     = `Arme Fedtmasse`, ## arm fat mass (kg)
    FM_leg     = `Ben Fedtmasse`, ## leg fat mass (kg)
    FM_trunk   = `Truncus diff Fedtmasse` ## trunk fat mass (kg)
  ) %>%
  # Recode gender variable
  dplyr::mutate(
    gender = dplyr::case_when(
      gender == 1 ~ 0, # male (1) --> 0
      gender == 2 ~ 1, # male (2) --> 1
      TRUE ~ NA_real_
    )
  ) %>%
  ## Compute derived body composition variables
  dplyr::mutate(
    FMI                    = FM / ((height / 100)^2), ## FMI (kg/m^2)
    FM_trunk_quotient_limb = FM_trunk / (FM_arm + FM_leg), ## FM_trunk_quotient_limb
    LMI                    = LM / ((height / 100)^2), ## LMI (kg/m^2)
    appendicular_LMI       = (LM_arm + LM_leg) / ((height / 100)^2), ## appendicular_LMI (kg/m^2)
    BMI                    = weight / ((height / 100)^2) ## BMI (kg/m^2)
    # fitted_FMI             = FM / ((height/100)^x_fm), ## fitted_FMI (kg/m^x_fm)
    # fitted_LMI             = LM / ((height/100)^x_lm), ## fitted_LMI (kg/m^x_lm)
    # fitted_ALMI            = (LM_arm + LM_leg) / ((height/100)^x_alm), ## fitted_ALMI (kg/m^x_alm)
    # fitted_BMI             = weight / ((height/100)^x_bmi) ## fitted_BMI (kg/m^x_bmi)
    # VAT_mass               = (?) ## VAT_mass (g)
  ) %>%
  ## Keep only relevant columns for zscore computation
  dplyr::select(
    PATID,
    age,
    appendicular_LMI,
    BMI,
    # FM_android_quotient_gynoid,
    FM_trunk_quotient_limb,
    FMI,
    # fitted_ALMI,
    # fitted_BMI,
    # fitted_FMI,
    # fitted_LMI,
    gender,
    height,
    LMI,
    # VAT_mass,
    weight,
    percent_FM
  )


# --- Compute zscores -----------------------------------------------------------
# dxa_data_new will contain the original columns `value` + the corresponding `zscore-value` columns
dxa_data_new <- compute_zscores_file(data = dxa_data)

# --- Save dxa zscores data -----------------------------------------------------
# write.csv(dxa_data_new, dxa_zscores_path, row.names = FALSE)

# --- optional : Visualize reference percentile curves --------------------------
# Example usage
# plot <- create_plot(
#   ref_data_path = "LMS_data/",
#   age_group = "children",
#   value = "percent_FM",
#   gender = 0
# )
# print(plot)

# --- optional : Test the compute_zscores_function with example file -----------
# your_filename = "example_file.xlsx"
# compute_zscores_file(filename = your_filename)
