library(dplyr)

# This function computes Z-scores for specified measurements based on
# the reference values extracted from an age- and gender-specific LMS_data reference
# files in data/. It takes as input the reference data, processes it
# according to specified age groups and genders, and outputs an updated data
# frame with the computed Z-scores.
# column names for this function to work should be:
## gender : male (0) or female (1)
## age
## percent_FM
## FMI
## LMI
## appendicular_LMI
## ...

compute_zscores_file <- function(data,
                                 datapath = "data/",
                                 min_age = 6.0,
                                 max_age = 82.0,
                                 child_adult_split = 18.0,
                                 eps = 0.001
                                ) {
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
      new_col <- paste0("zscore-", value)
      # Loop through each gender, i.e. male (0) or female (1)
      for (gender in c(0, 1)) {
        # Loop through each age group; i.e. children (6-18) or adult (18-82)
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
              LMS_data_file_name <- paste0("data/children_LMS_", value, "_gender", as.character(gender), ".csv")
            } else {
              LMS_data_file_name <- paste0("data/adults_LMS_", value, "_gender", as.character(gender), ".csv")
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
  # Save the updated data frame to a new CSV file
  # output_filename <- paste0("output_", tools::file_path_sans_ext(basename(filename)), ".csv")
  # write.csv(data, output_filename)
}