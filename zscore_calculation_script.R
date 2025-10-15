# --- Load libraries ------------------------------------------------------------
library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)

# --- Load DXA data and external functions --------------------------------------
source("load_data.R")
source("compute_zscores.R")

# --- Compute zscores -----------------------------------------------------------
# dxa_data_new will contain the original columns `value` + the corresponding 
# `zscore-value` columns
dxa_data_zscores <- compute_zscores(data = dxa_data)

# --- Save dxa zscores data -----------------------------------------------------
# dxa_zscores_path <- "write_folder_path_here/dxa_data_zscores.csv")
# write.csv(dxa_data_zscores, dxa_zscores_path, row.names = FALSE)