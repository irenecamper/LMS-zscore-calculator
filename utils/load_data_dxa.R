# =============================================================================
# DXA Body Composition Data Preparation Script
#
# Purpose:
#   Load and prepare DXA data for z-score computation.
#
# Input:
#   Excel file specified by `dxa_path`.
#
# Output:
#   `dxa_data` — a cleaned data frame containing:
#     - PATID: unique participant ID
#     - age: participant age (years)
#     - gender: recoded as 0 = male, 1 = female
#     - FMI: Fat Mass Index (kg/m^2)
#     - LMI: Lean Mass Index (kg/m^2)
#     - BMI: Body Mass Index (kg/m^2)
#     - appendicular_LMI: Appendicular Lean Mass Index (kg/m^2)
#     - FM_trunk_quotient_limb: Trunk-to-limb fat mass ratio
#     - percent_FM: Percent fat mass
#     - height, weight: Anthropometrics
# =============================================================================

# --- Setup -------------------------------------------------------------------
library(readxl)
library(dplyr)

dxa_path <- "/Volumes/auditing-groupdirs/SUN-CBMR-HOLBAEK/database freeze/2023_March/DXA-scans_ALL/dexa_sub.v.03.2023.xlsx"

# --- Load and prepare DXA data -----------------------------------------------
dxa_data <- read_excel(dxa_path, col_names = TRUE) |>
  dplyr::mutate(
    age = as.numeric(difftime(as.Date(dexa_date, format = "%Y-%m-%d"),
                              as.Date(dexa_birth_date, format = "%Y-%m-%d"),
                              units = "days")) / 365.25
  ) |>
  # --- Rename variables ------------------------------------------------------
  dplyr::rename(
    PATID      = pat_ID,                     # Unique participant ID
    percent_FM = fat_percent,                # % fat mass
    gender     = dexa_gender,                # Gender: male (1) / female (2)
    FM         = `Total Fedtmasse`,          # Total fat mass (kg)
    LM         = `Total Fedtfri masse`,      # Total lean mass (kg)
    FM_arm     = `Arme Fedtmasse`,           # Arm fat mass (kg)
    FM_leg     = `Ben Fedtmasse`,            # Leg fat mass (kg)
    FM_trunk   = `Truncus diff Fedtmasse`,   # Trunk fat mass (kg)
    LM_arm     = `Arme Fedtfri masse`,       # Arm lean mass (kg)
    LM_leg     = `Ben Fedtfri masse`,        # Leg lean mass (kg)
    height     = dexa_height,                # Height (cm)
    weight     = dexa_weight                 # Weight (kg)
  ) |>
  # --- Recode gender ---------------------------------------------------------
  dplyr::mutate(
    gender = case_when(
      gender == 1 ~ 0,  # male   → 0
      gender == 2 ~ 1   # female → 1
    )
  ) |>
  # --- Compute derived indices ----------------------------------------------
  dplyr::mutate(
    FMI                    = FM / ((height / 100)^2),              # Fat Mass Index (kg/m^2)
    LMI                    = LM / ((height / 100)^2),              # Lean Mass Index (kg/m^2)
    appendicular_LMI       = (LM_arm + LM_leg) / ((height / 100)^2), # Appendicular Lean Mass Index (kg/m^2)
    BMI                    = weight / ((height / 100)^2),          # Body Mass Index (kg/m^2)
    FM_trunk_quotient_limb = FM_trunk / (FM_arm + FM_leg)          # Trunk/Limb fat ratio
  ) |>
  # --- Select relevant columns ----------------------------------------------
  dplyr::select(
    PATID,
    age,
    gender,
    height,
    weight,
    percent_FM,
    FMI,
    LMI,
    BMI,
    appendicular_LMI,
    FM_trunk_quotient_limb
    # FM_android_quotient_gynoid,
    # fitted_ALMI, fitted_BMI, fitted_FMI, fitted_LMI,
    # VAT_mass
  )
