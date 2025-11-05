library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)
library(gamlss)

# =============================================================================
# DXA BODY COMPOSITION DATA PREPARATION
# -----------------------------------------------------------------------------
# Purpose:
#   Load and prepare DXA data for z-score computation.
#
# Input:
#   - Excel file specified by `dxa_path`
#
# Output:
#   - `dxa_data`: cleaned dataset including
#       PATID                Participant ID
#       age                  Age (years)
#       gender               0 = male, 1 = female
#       height, weight       Anthropometrics (cm, kg)
#       FMI, LMI, BMI        Fat, Lean, and Body Mass Indices (kg/m²)
#       appendicular_LMI     Appendicular Lean Mass Index (kg/m²)
#       FM_trunk_quotient_limb  Trunk-to-limb fat mass ratio
#       percent_FM           Percent fat mass
# =============================================================================

# >>> EDIT HERE if using a different DXA file <<<
dxa_path <- "/Volumes/auditing-groupdirs/SUN-CBMR-HOLBAEK/database freeze/2023_March/DXA-scans_ALL/dexa_sub.v.03.2023.xlsx"

# --- Load and prepare DXA data -----------------------------------------------
dxa_data <- read_excel(dxa_path, col_names = TRUE) |>
  mutate(
    age = as.numeric(difftime(as.Date(dexa_date),
                              as.Date(dexa_birth_date),
                              units = "days")) / 365.25
  ) |>
  rename(
    ## new_variable_name = old_variable_name
    PATID      = pat_ID,
    percent_FM = fat_percent,
    gender     = dexa_gender,
    FM         = `Total Fedtmasse`,
    LM         = `Total Fedtfri masse`,
    FM_arm     = `Arme Fedtmasse`,
    FM_leg     = `Ben Fedtmasse`,
    FM_trunk   = `Truncus diff Fedtmasse`,
    LM_arm     = `Arme Fedtfri masse`,
    LM_leg     = `Ben Fedtfri masse`,
    height     = dexa_height,
    weight     = dexa_weight
  ) |>
  mutate(
    gender = case_when(
      gender == 1 ~ 0,  # male
      gender == 2 ~ 1   # female
    ),
    FMI                    = FM / ((height / 100)^2),
    LMI                    = LM / ((height / 100)^2),
    appendicular_LMI       = (LM_arm + LM_leg) / ((height / 100)^2),
    BMI                    = weight / ((height / 100)^2),
    FM_trunk_quotient_limb = FM_trunk / (FM_arm + FM_leg)
  ) |>
  select(PATID, age, gender, height, weight, percent_FM,
         FMI, LMI, BMI, appendicular_LMI, FM_trunk_quotient_limb)
         

# =============================================================================
# WAIST–HIP DATA PREPARATION
# -----------------------------------------------------------------------------
# Purpose:
#   Load, clean, and prepare population-based (reference) and local datasets
#   for z-score computation.
#
# Inputs:
#   1. Reference dataset (CSV): used as population reference for z-scores
#        e.g. "Insulin_data_pop.csv"
#
#   2. Local dataset (Excel):
#        e.g. "example_file.xlsx"
#
# Outputs:
#   - ref_data:     cleaned reference data with derived ratios
#   - example_data: local dataset, harmonized for z-score computation
#
# =============================================================================

ref_data_path <- "/Volumes/auditing-groupdirs/SUN-CBMR-HOLBAEK/data analysis/data_tools/Frithioff-Boejsoe_2019/Insulin_data_pop.csv"  # <-- EDIT if using a different reference dataset
example_path  <- "example_file.xlsx"  # >>> EDIT THis PATHS to use a local data set <<<

# --- Load reference dataset --------------------------------------------------
ref_data <- utils::read.csv2(ref_data_path, as.is = TRUE, na.strings = c("", "NA")) |>
  mutate(
    age = as.numeric(difftime(as.Date(visit_date),
                              as.Date(birth_date),
                              units = "days")) / 365.25,
    gender = case_when(
      gender == 1 ~ 0,
      gender == 2 ~ 1,
      TRUE ~ NA_real_
    ),
    waist_hip_ratio    = ifelse(hip > 0, waist / hip, NA_real_),
    waist_height_ratio = ifelse(height > 0, waist / height, NA_real_)
  ) |>
  rename(PATID = pat_ID) |>
  select(PATID, age, gender, height, waist, hip, waist_hip_ratio, waist_height_ratio)

# --- Load example (local) dataset --------------------------------------------
example_data <- read_excel(example_path) |>
  # >>> UNCOMMENT AND EDIT BELOW if variable names differ <<<
  # rename(
  #   PATID = old_PATID_var, 
  #   gender = old_gender_var,
  #   waist  = old_waist_var,
  #   hip    = old_hip_var,
  #   height = old_height_var,
  #   age    = old_age_var
  # ) |>
  select(PATID, age, gender, waist, hip, height) |>
  mutate(
    waist_hip_ratio    = ifelse(hip > 0, waist / hip, NA_real_),
    waist_height_ratio = ifelse(height > 0, waist / height, NA_real_)
  )

# =============================================================================
# FUNCTION: compute_zscores_from_LMS_data
# -----------------------------------------------------------------------------
# Purpose:
#   Compute z-scores for DXA-derived variables using LMS reference files.
#   Reference files must be located in `LMS_data/`.
#
# Input requirements:
#   - `data`: data.frame with the following columns:
#       * age       : numeric, participant age in years
#       * gender    : 0 = male, 1 = female
#       * one or more numeric variables to compute z-scores for
#       * (optional) PATID : participant ID
#
#   - `datapath`: character string specifying the path to the LMS reference files.
#     Each file should follow the naming pattern:
#       * "children_LMS_<variable>_gender0.csv"
#       * "children_LMS_<variable>_gender1.csv"
#       * "adults_LMS_<variable>_gender0.csv"
#       * "adults_LMS_<variable>_gender1.csv"
#
# Output:
#   Returns the same data frame as input, with additional columns:
#     zscore_<variable> : numeric LMS-based z-scores for each variable
#
# Notes:
#   - Missing or unmatched LMS reference files trigger a warning.
#   - Age boundaries (default: 6–18 for children, 18–82 for adults) can be adjusted.
# =============================================================================

compute_zscores_from_LMS_data <- function(data,
                                          datapath = "LMS_data/",
                                          min_age = 6.0,
                                          max_age = 82.0,
                                          child_adult_split = 18.0,
                                          eps = 0.001) {
  if (!all(c("age", "gender") %in% names(data))) {
    stop("Input data must include columns: age and gender.")
  }

  for (value in setdiff(names(data), c("age", "gender", "PATID"))) {
    message("Computing z-scores for: ", value)
    new_col <- paste0("zscore_", value)

    for (gender in c(0, 1)) {
      for (age_int in list(c(min_age, child_adult_split), c(child_adult_split, max_age))) {
        subset_idx <- which(data$age >= age_int[1] & data$age < age_int[2] & data$gender == gender)
        data_curr <- data[subset_idx, ]

        if (nrow(data_curr) == 0) next

        if (age_int[1] == min_age) {
          LMS_file <- paste0(datapath, "children_LMS_", value, "_gender", gender, ".csv")
        } else {
          LMS_file <- paste0(datapath, "adults_LMS_", value, "_gender", gender, ".csv")
        }

        if (!file.exists(LMS_file)) {
          warning("LMS file not available: ", LMS_file)
          data[subset_idx, new_col] <- NA
          next
        }

        LMS_data <- read.csv(LMS_file) |> select(age, lambda, sigma, mu)
        zscores <- numeric(nrow(data_curr))

        for (i in seq_len(nrow(data_curr))) {
          j <- which.min(abs(LMS_data$age - data_curr$age[i]))
          L <- LMS_data$lambda[j]; M <- LMS_data$mu[j]; S <- LMS_data$sigma[j]
          y <- data_curr[[value]][i]

          zscores[i] <- if (abs(L) > eps) {
            ((y / M)^L - 1) / (L * S)
          } else {
            log(y / M) / S
          }
        }

        data[subset_idx, new_col] <- zscores
      }
    }
  }
  return(data)
}


# =============================================================================
# FUNCTION: compute_zscores_from_ref_data
# -----------------------------------------------------------------------------
# Purpose:
#   Compute z-scores for anthropometric variables (e.g., waist, hip, WHR)
#   using reference population data fitted via GAMLSS models.
#
# Input requirements:
#   - `data`: data.frame containing at least:
#       * age       : numeric, age in years
#       * gender    : 0 = male, 1 = female
#       * variables listed in `values`
#
#   - `ref_data`: data.frame containing the same variable names and structure
#     as `data`. Used as reference for fitting GAMLSS models.
#
#   - `values`: character vector of variable names to compute z-scores for.
#     Defaults to: c("waist", "hip", "waist_hip_ratio", "waist_height_ratio")
#
# Output:
#   Returns the same data frame as input, with additional columns:
#     zscore_<variable> : numeric z-scores based on the fitted GAMLSS model.
#
# Notes:
#   - Fits models separately for males (0) and females (1).
#   - Requires the `gamlss` package and uses the BCPE family by default.
#   - Missing or zero-length reference subsets for a gender/variable are skipped.
# =============================================================================

compute_zscores_from_ref_data <- function(data,
                                          ref_data,
                                          values = c("waist", "hip", "waist_hip_ratio", "waist_height_ratio")) {
  
  if (!requireNamespace("gamlss", quietly = TRUE)) {
    stop("Package 'gamlss' must be installed.")
  }

  missing_vars <- setdiff(values, names(data))
  if (length(missing_vars) > 0) {
    stop("The following variables are missing from `data`: ", paste(missing_vars, collapse = ", "))
  }

  missing_ref_vars <- setdiff(values, names(ref_data))
  if (length(missing_ref_vars) > 0) {
    stop("The following variables are missing from `ref_data`: ", paste(missing_ref_vars, collapse = ", "))
  }

  for (value in values) {
    zscores <- numeric(nrow(data))
    new_col <- paste0("zscore_", value)

    for (g in c(0, 1)) {
      ref_subset <- ref_data |> filter(gender == g) |> select(age, gender, !!sym(value)) |> na.omit()
      
      if (nrow(ref_subset) == 0) {
        warning("Reference subset empty for variable '", value, "' and gender ", g, ".")
        next
      }

      model <- suppressWarnings(
        gamlss::gamlss(as.formula(paste(value, "~ pb(age)")), data = ref_subset, family = BCPE)
      )

      idx <- which(data$gender == g)
      if (length(idx) == 0) next

      pred <- suppressWarnings(
        gamlss::centiles.pred(model,
                              xname = "age",
                              xvalues = data$age[idx],
                              yval = data[[value]][idx],
                              type = "z-scores",
                              data = ref_subset)
      )
      zscores[idx] <- pred
    }

    data[[new_col]] <- zscores
  }

  return(data)
}

# =============================================================================
# Z-SCORE COMPUTATION PIPELINE
# -----------------------------------------------------------------------------
# Purpose:
#   Compute z-scores for both anthropometric and DXA-derived measures.
# =============================================================================

data_zscores <- compute_zscores_from_ref_data(
  data     = example_data,
  ref_data = ref_data,
  values   = c("hip", "waist", "waist_hip_ratio", "waist_height_ratio")
)

dxa_data_zscores <- compute_zscores_from_LMS_data(
  data     = dxa_data,
  datapath = "LMS_data/"
) |>
  rename(zscore_BMI_LEAD = zscore_BMI)

# --- Optional: Save results --------------------------------------------------
# write.csv(data_zscores, "data_zscores.csv", row.names = FALSE)
# write.csv(dxa_data_zscores, "dxa_data_zscores.csv", row.names = FALSE)