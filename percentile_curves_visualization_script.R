# --- Load libraries ------------------------------------------------------------
library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)

# --- Load DXA data and external functions --------------------------------------
source("utils/vis_functions.R")
source("utils/load_data.R")

plot_percentile_curves(
  ref_data_path = "LMS_data/",
  age_group = "children",
  measurement = "percent_FM",
  gender_value = 0
)

create_histogram(
  age_group = "NULL",
  value = "percent_FM",
  gender_value = 0,
  data = dxa_data
)

# Example assuming you have df with columns: age, gender, percent_FM, etc.
plot_percentile_with_points(
  ref_data_path = "LMS_data/",
  age_group = "children",
  measurement = "percent_FM",
  gender_value = 1,
  data = dxa_data
)

# Example assuming you have df with columns: age, gender, percent_FM, etc.
plot_percentile_with_points(
  ref_data_path = "LMS_data/",
  age_group = "children",
  measurement = "percent_FM",
  gender_value = 0,
  data = dxa_data
)
