#' Compute z-scores from reference data using GAMLSS
#'
#' @description
#' Computes z-scores for specified variables (e.g., waist, hip, WHR)
#' using reference data and GAMLSS models fit separately by gender.
#'
#' @param data Data frame with `age`, `gender`, and variables listed in `values`.
#' @param ref_data Reference data with the same structure as `data`.
#' @param values Character vector of variables to compute z-scores for.
#'   Default: `c("waist", "hip", "WHR")`.
#'
#' @return A data frame with additional `zscore_<variable>` columns.
#'
compute_zscores_from_ref_data <- function(data, ref_data, values = c("waist", "hip", "WHR")) {
  if (!requireNamespace("gamlss", quietly = TRUE)) {
    stop("Package 'gamlss' must be installed.")
  }

  for (value in values) {
    zscores <- numeric(nrow(data))
    new_col <- paste0("zscore_", value)

    for (gender_value in c(0, 1)) {
      ref_data_curr <- ref_data |>
        filter(gender == gender_value) |>
        select(PATID, age, !!sym(value), gender) |>
        na.omit()

      gamlss_model <- suppressWarnings(
        suppressMessages(gamlss::gamlss(
          as.formula(paste(value, "~ pb(age)")),
          data = ref_data_curr,
          family = gamlss::BCPE
        ))
      )

      idx <- which(data$gender == gender_value)

      pred <- suppressWarnings(
        suppressMessages(gamlss::centiles.pred(
          gamlss_model,
          xname = "age",
          xvalues = data$age[idx],
          yval = data[[value]][idx],
          type = "z-scores",
          data = ref_data_curr
        ))
      )

      zscores[idx] <- pred
    }

    data[[new_col]] <- zscores
  }

  return(data)
}
