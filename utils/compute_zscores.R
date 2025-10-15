#' Computation of zscores
#' 
#' @description
#' `compute_zscores` computes zscores for body composition measurements using age- and gender-specific LMS reference files.
#' Reference files are expected in the `LMS-data/` directory. Returns the original dataframe with added zscore columns.
#'
#' @param data A `data.frame` containing measurement data. Must include at least:
#'   \describe{
#'     \item{PATID}{unique participant ID (not required but recommended)}
#'     \item{age}{age in years}
#'     \item{gender}{0 for female, 1 for male}
#'     \item{appendicular_LMI, BMI, FM_android_quotient_gynoid, FM_trunk_quotient_limb,
#'           FMI, fitted_ALMI, fitted_BMI, fitted_FMI, fitted_LMI, LMI, VAT_mass, weight,
#'           height, percent_FM}{Optional measurement columns (not all required)}
#'   }
#' @param datapath Path to LMS reference data directory. Default: `"LMS_data/"`
#' @param min_age Minimum age for reference data (default 6.0)
#' @param max_age Maximum age for reference data (default 82.0)
#' @param child_adult_split Age to split children vs adults (default 18.0)
#' @param eps Small number to handle zero lambda values (default 0.001)
#'
#' @return A `data.frame` identical to input, with additional columns for zscores named `zscore_<measurement>`.
#'
#' @details
#' The function loops through all measurement columns (except `age`, `gender`, `PATID`)
#' and computes zscores for each combination of gender and age group. Missing LMS files or missing columns result in `NA` values.
#'
#' @examples
#' \dontrun{
#' library(readxl)
#' data <- readxl::read_excel("example_file.xlsx")
#' data_zscores <- compute_zscores_file(data = data, datapath = "LMS-data/")
#' write.csv(data_zscores, "data_zscores.csv", row.names = FALSE)
#' }
compute_zscores <- function(data,
                            datapath = "LMS_data/",
                            min_age = 6.0,
                            max_age = 82.0,
                            child_adult_split = 18.0,
                            eps = 0.001) {
  if (!("age" %in% colnames(data)) || !("gender" %in% colnames(data))) {
    stop(sprintf("File does not have the columns: age and gender"))
  }

  # Loop through each column in the data frame
  for (value in colnames(data)) {
    # Check if the column is not one of the measurements of interest
    if (!(value %in% c("age", "gender", "PATID"))) {
      # Print the measurement being processed
      cat(sprintf("Computing zscores for: %s\n", value))
      # Create new column name
      new_col <- paste0("zscore_", value)
      # Loop through each gender, i.e. male (0) or female (1)
      for (gender in c(0, 1)) {
        # Loop through each age group; i.e. children [6, 18) or adult [18, 82)
        for (age_int in list(c(min_age, child_adult_split), c(child_adult_split, max_age))) {
          # Subset the data based on gender and age group.
          # note: we will have 4 data_curr: female-children, female-adult, male-children, male-adult
          data_curr <- data[data[["age"]] >= age_int[1] & data[["age"]] < age_int[2] & data[["gender"]] == gender, ]

          # Check if the current data frame is not empty
          if (nrow(data_curr) > 0) {
            # Extract y_vals and t_vals from the data frame
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
              column_names <- c("age", "lambda", "mu", "sigma")
              LMS_data <- as.data.frame(read.csv(LMS_data_file_name, header = TRUE)) %>%
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
