# Libraries ----
library(bsicons)
library(bslib)
library(ggplot2)
library(dplyr)
library(tidyr)
library(shiny)
library(dplyr)
library(tidyr)

# Functions ----
source("../compute_zscores.R")
source("../create_plot.R")

# Data ----
values <- c(
  "FMI",
  "LMI",
  "FM_trunk_quotient_limb",
  "FM_android_quotient_gynoid",
  "appendicular_LMI",
  "percent_FM",
  "VAT_mass",
  "fitted_FMI",
  "fitted_LMI",
  "fitted_BMI",
  "fitted_ALMI",
  "BMI",
  "height",
  "weight"
)
# Parameters ----
CHOICES <- list(
  value = values,
  age_group = c("children", "adults"),
  gender = c(1, 0)
  
)

PRIMARY <- "#CCC5BD"

