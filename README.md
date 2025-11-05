## Overview

This repository provides a R-based pipeline for computing **Z-scores** for both **DXA-derived** and **anthropometric** measurements. Z-scores for DXA-based measurements using LMS model outputs from the Austrian LEAD Study and anthropometric measurements are derived from reference data, also loaded in the script.

The workflow is now consolidated into a single script `zscore_calculation_script.R`, which loads and prepares both DXA and anthropometric data, computes all corresponding Z-scores, and optionally saves the results.

The LMS-based computations are adapted from [the scientific LMS Z-Score App](https://github.com/FlorianKrach/scientific-LMS-zscore-app), which utilizes LMS methodology originally implemented in Python. The data files are sourced from resources in the original repository. LMS values and percentile curves for children and adults can be found at [the following link: [LMS Z-Score App Data]](https://github.com/FlorianKrach/scientific-LMS-zscore-app/tree/master/data). The relevant outputs have been saved in the `LMS_data/` folder in this repository.

## Requirements
- **Required R packages**:
  ```r
  install.packages(c("dplyr", "readxl", "ggplot2", "tidyr", "gamlss", "shiny", "bslib"))
  ```

## Calculated Z-Scores
### DXA-Based Measurements (LMS Reference)
* DXA Z-scores for % Fat Mass (%FM) (available for 6-18-year-olds)
* DXA Z-scores for Fat Mass Index (FMI) (available for 6-18-year-olds & 18-81-year-olds)
* DXA Z-scores for Lean Mass Index (LMI) (available for 6-18-year-olds & 18-81-year-olds)
* DXA Z-scores for Appendicular Lean Mass Index (ALMI) (available for 6-18-year-olds & 18-81-year-olds)
* DXA Z-scores for Trunk/Limb Fat Mass Ratio (available for 6-18-year-olds & 18-81-year-olds)
### Anthropometric Measurements (Reference Data + GAMLSS)
* Z-scores for Waist Circumference
* Z-scores for Hip Circumference
* Z-scores for Waist-to-Height Ratio

## Reference
This code can be used to compute Z-scores of body composition parameters with the reference values for:

adults published in:
Article Title: Reference values of body composition parameters and visceral adipose tissue (VAT) by DXA in adults aged 18–81 years—results from the LEAD cohort
DOI: 10.1038/s41430-020-0596-5, 2019EJCN0971
Link: https://www.nature.com/articles/s41430-020-0596-5
Citation: Ofenheimer, A., Breyer-Kohansal, R., Hartl, S. et al. Reference values of body composition parameters and visceral adipose tissue (VAT) by DXA in adults aged 18–81 years—results from the LEAD cohort. Eur J Clin Nutr (2020).

children published in:
Article Title: Reference charts for body composition parameters by dual‐energy X‐ray absorptiometry in European children and adolescents aged 6 to 18 years—Results from the Austrian LEAD (Lung, hEart , sociAl , boDy ) cohort
Link: http://dx.doi.org/10.1111/ijpo.12695
Citation: Ofenheimer, A, Breyer‐Kohansal, R, Hartl, S, et al. Reference charts for body composition parameters by dual‐energy X‐ray absorptiometry in European children and adolescents aged 6 to 18 years—Results from the Austrian LEAD (Lung, hEart , sociAl , boDy ) cohort. Pediatric Obesity. 2020;e12695. https://doi.org/10.1111/ijpo.12695
