#' Compute z-scores from LMS reference files
#'
#' @description
#' Computes z-scores for body composition measurements using age- and gender-specific LMS reference files.
#' Reference files must be located in the `LMS_data/` directory.
#'
#' @param data A `data.frame` containing at least columns `age` and `gender`.
#' @param datapath Directory path to LMS reference CSV files (default `"LMS_data/"`).
#' @param min_age Minimum reference age (default 6.0).
#' @param max_age Maximum reference age (default 82.0).
#' @param child_adult_split Age threshold between child/adult references (default 18.0).
#' @param eps Small value to avoid division by zero when lambda ≈ 0 (default 0.001).
#'
#' @return A `data.frame` with additional `zscore_<measurement>` columns.
#'
compute_zscores_from_LMS_data <- function(data,
                            datapath = "LMS_data/",
                            min_age = 6.0,
                            max_age = 82.0,
                            child_adult_split = 18.0,
                            eps = 0.001) {
  if (!all(c("age", "gender") %in% names(data))) {
    stop(sprintf("File does not have the columns: age and gender"))
  }

  for (value in colnames(data)) {
    if (!(value %in% c("age", "gender", "PATID"))) {
      message("Computing z-scores for: ", value)
      new_col <- paste0("zscore_", value)
      # Loop through each gender, i.e. male (0) or female (1)
      for (gender in c(0, 1)) {
        # Loop through each age group; i.e. children [6, 18) or adult [18, 82)
        for (age_int in list(c(min_age, child_adult_split), c(child_adult_split, max_age))) {
          # Subset the data based on gender and age group.
          # note: we will have 4 data_curr: female-children, female-adult, male-children, male-adult
          data_curr <- data[data[["age"]] >= age_int[1] & data[["age"]] < age_int[2] & data[["gender"]] == gender, ]

          if (nrow(data_curr) > 0) {

            y_vals <- data_curr[[value]] # measured response variable
            t_vals <- data_curr[["age"]] # predictor variable

            zscores <- numeric(length(t_vals))

            # Determine the reference file based on age and gender
            if (age_int[1] == min_age) {
              LMS_data_file_name <- paste0(datapath, "children_LMS_", value, "_gender", as.character(gender), ".csv")
            } else {
              LMS_data_file_name <- paste0(datapath, "adults_LMS_", value, "_gender", as.character(gender), ".csv")
            }

            if (file.exists(LMS_data_file_name)) {
              
              LMS_data <- as.data.frame(read.csv(LMS_data_file_name, header = TRUE)) |>
                dplyr::select("age", "lambda", "sigma", "mu")

              LMS_data <- as.data.frame(LMS_data)

              for (i in 1:length(t_vals)) {
                j <- which.min(abs(LMS_data$age - t_vals[i]))
                L_vals <- LMS_data[j, "lambda"]
                M_vals <- LMS_data[j, "mu"]
                S_vals <- LMS_data[j, "sigma"]

                if (abs(LMS_data[j, "lambda"]) > eps) {
                  z <- ((y_vals[i] / LMS_data[j, "mu"])**(LMS_data[j, "lambda"]) - 1) / (LMS_data[j, "lambda"] * LMS_data[j, "sigma"])
                } else {
                  z <- log(y_vals[i] / LMS_data[j, "mu"]) / LMS_data[j, "sigma"]
                }
                zscores[i] <- z
              }
            } else {
              zscores[] <- NA
            }

            data[data[["age"]] >= age_int[1] & data[["age"]] < age_int[2] & data[["gender"]] == gender, new_col] <- zscores
          }
        }
      }
    }
  }
  return(data)
}