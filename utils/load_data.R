# =============================================================================
# Script to load and prepare DXA body composition data for zscore calculation
#
# Input: DXA Excel file (path specified in `dxa_path`)
# Output: `dxa_data` dataframe with age, gender, body composition indices (FMI,
# LMI, BMI, appendicular_LMI, FM trunk/limb ratio, etc.)
# =============================================================================

# --- Define DXA data input path -----------------------------------------
dxa_path <- "/Volumes/auditing-groupdirs/SUN-CBMR-HOLBAEK/database freeze/2023_March/DXA-scans_ALL/dexa_sub.v.03.2023.xlsx"

# --- Load and prepare DXA data ------------------------------------------
library(readxl)
library(dplyr)

dxa_data <- read_excel(dxa_path, col_names = TRUE) %>%
  # --- Rename variables --------------------------------------------------
  dplyr::rename(
    PATID      = pat_ID, # Unique participant ID
    percent_FM = fat_percent, # % fat mass
    gender     = dexa_gender, # Gender: male (1) / female (2)
    age        = dexa_age, # Age in years
    FM         = `Total Fedtmasse`, # Total fat mass (kg)
    height     = dexa_height, # Height (cm)
    weight     = dexa_weight, # Weight (kg)
    LM         = `Total Fedtfri masse`, # Total lean mass (kg)
    LM_arm     = `Arme Fedtfri masse`, # Arm lean mass (kg)
    LM_leg     = `Ben Fedtfri masse`, # Leg lean mass (kg)
    FM_arm     = `Arme Fedtmasse`, # Arm fat mass (kg)
    FM_leg     = `Ben Fedtmasse`, # Leg fat mass (kg)
    FM_trunk   = `Truncus diff Fedtmasse` # Trunk fat mass (kg)
  ) %>%
  # --- Recode gender -----------------------------------------------------
  dplyr::mutate(
    gender = case_when(
      gender == 1 ~ 0, # male   --> 0
      gender == 2 ~ 1 # female --> 1
    )
  ) %>%
  # --- Compute derived body composition variables -----------------------
  dplyr::mutate(
    FMI                    = FM / ((height / 100)^2), # Fat Mass Index (kg/m^2)
    FM_trunk_quotient_limb = FM_trunk / (FM_arm + FM_leg), # Trunk / limb fat mass ratio
    LMI                    = LM / ((height / 100)^2), # Lean Mass Index (kg/m^2)
    appendicular_LMI       = (LM_arm + LM_leg) / ((height / 100)^2), # Appendicular LMI (kg/m^2)
    BMI                    = weight / ((height / 100)^2) # Body Mass Index (kg/m^2)
    # fitted_FMI  = FM / ((height/100)^x_fm),
    # fitted_LMI  = LM / ((height/100)^x_lm),
    # fitted_ALMI = (LM_arm + LM_leg) / ((height/100)^x_alm),
    # fitted_BMI  = weight / ((height/100)^x_bmi)
    # VAT_mass    = (?) # Visceral Adipose Tissue mass in grams
  ) %>%
  # --- Keep only relevant columns for zscore computation ----------------
  dplyr::select(
    PATID,
    age,
    appendicular_LMI,
    BMI,
    FM_trunk_quotient_limb,
    FMI,
    gender,
    height,
    LMI,
    weight,
    percent_FM # ,
    # FM_android_quotient_gynoid,
    # fitted_ALMI, fitted_BMI, fitted_FMI, fitted_LMI,
    # VAT_mass
  )
