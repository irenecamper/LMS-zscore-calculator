# =============================================================================
# Z-Score Computation Pipeline
#
# Purpose:
#   Load data, compute z-scores for anthropometric and DXA-derived measures
#   using reference datasets and LMS reference files.
#
# Inputs:
#   - Reference and example data (from `load_data.R`)
#   - DXA data (from `load_data_dxa.R`)
#   - External utility functions for z-score computation:
#       * compute_zscores_from_ref_data.R
#       * compute_zscores_from_LMS.R
#
# Outputs:
#   - data_zscores: example data with z-scores for waist, hip, WHR
#   - dxa_data_zscores: DXA data with LMS-based z-scores
#   (optionally saved to CSV)
# =============================================================================

# --- Setup -------------------------------------------------------------------
library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)
library(gamlss)

# --- Load external functions and data ----------------------------------------
source("utils/compute_zscores_from_LMS.R")
source("utils/compute_zscores_from_ref_data.R")
source("utils/load_data.R")
source("utils/load_data_dxa.R")

# --- Compute z-scores ---------------------------------------------------------
hospital_data_zscores <- compute_zscores_from_ref_data(
  data = hospital_data,
  ref_data = pop_data,
  values = c("hip", "waist", "waist_hip_ratio", "waist_height_ratio")
)

dxa_data_zscores <- compute_zscores_from_LMS_data(
  data = dxa_data,
  datapath = "LMS_data/"
) |>
  dplyr::rename(
    zscore_BMI_LEAD = zscore_BMI
  )

# --- Optional: Save outputs ---------------------------------------------------
# write.csv(hospital_data_zscores, "hospital_data_zscores.csv", row.names = FALSE)
# write.csv(dxa_data_zscores, "dxa_data_zscores.csv", row.names = FALSE)
