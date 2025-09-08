# LMS-zscore-calculator
This repository contains R code for calculating Z-scores from measurement data based on age and gender-specific reference values. It supports both CSV and Excel input formats and generates an updated dataset with the calculated Z-scores.

## Overview
The R code, along with necessary data files, enables the calculation of Z-scores from anthropometric measurement data using LMS model outputs adapted from the Austrian LEAD Study. This adaptation derives from the scientific LMS Z-Score App, which utilizes LMS methodology originally implemented in Python. The data files are sourced from resources in the original repository.

## Requirements
- **R**: Version 4.0 or higher recommended
- **Required R packages**:
  - `dplyr`
  - `readxl`

## Data
LMS values and percentile curves for children and adults can be found at the following link: [LMS Z-Score App Data]. The relevant outputs have been saved in the `data/` folder in this repository.

## Instructions
1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Prepare the input data**: The filename should be something like `output_example_filename.csv` and it should contain the column names `age`, `gender` (0 for males, 1 for females), antropological measures you wish to calculate the Z-scores for, e.g. `FMI`. It is crucial that the column names have the same names.
   
4. **Run the Script**: Use the following command to run the R script that computes Z-scores:
  ```r
  source("compute_zscores.R")
  compute_zscores_file(filename = "output_example_filename.xlsx")
  ```
4. **Output**: The script will generate a file named `output_output_example_filename.csv`, which will contain the existing measurements alongside the newly calculated Z-scores, with columns prefixed by `zscore_` (e.g., `zscore_FMI`).

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

## Example Usage
To run the Z-score calculation, you can use the following code:
```r
compute_zscores_file(filename = "output_example_filename.xlsx")
```
This will read the data, compute the Z-scores, and save them to a new file.

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
