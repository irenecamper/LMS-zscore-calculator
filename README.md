# LMS-zscore-calculator
This repository contains R code for calculating Z-scores from measurement data based on age and gender-specific reference values.

## Overview
The script `zscore_calculation_script.R` computes standardized Z-scores for DXA-based measurements using LMS model outputs adapted from the Austrian LEAD Study. It also allows visualization of the reference percentile curves for any measurement, age group, and gender, using the provided `create_plot()` function.

The approach derives from [the scientific LMS Z-Score App](https://github.com/FlorianKrach/scientific-LMS-zscore-app), which utilizes LMS methodology originally implemented in Python. The data files are sourced from resources in the original repository.

## Requirements
- **R**: Version 4.0 or higher recommended
- **Required R packages**:
  ```r
  install.packages(c("dplyr", "readxl", "ggplot2", "tidyr"))
  ```

## Data
LMS values and percentile curves for children and adults can be found at [the following link: [LMS Z-Score App Data]](https://github.com/FlorianKrach/scientific-LMS-zscore-app/tree/master/data). The relevant outputs have been saved in the `data/` folder in this repository.

## Calculated Z-Scores
The script determines Z-scores for the following measurements:
* DXA Z-scores for % Fat Mass (%FM) (available for 6-18-year-olds)
* DXA Z-scores for Fat Mass Index (FMI) (available for 6-18-year-olds & 18-81-year-olds)
* DXA Z-scores for Lean Mass Index (LMI) (available for 6-18-year-olds & 18-81-year-olds)
* DXA Z-scores for Appendicular Lean Mass Index (ALMI) (available for 6-18-year-olds & 18-81-year-olds)
* DXA Z-scores for Trunk/Limb Fat Mass Ratio (available for 6-18-year-olds & 18-81-year-olds)

## Limitations
Please note that the following Z-scores are not currently generated.
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
