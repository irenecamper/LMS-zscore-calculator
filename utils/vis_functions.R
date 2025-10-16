# Global parameters
label_map <- c(p3 = "3 %", p10 = "10 %", p25 = "25 %", p50 = "50 %", p75 = "75 %", p90 = "90 %", p97 = "97 %")
measurement_map <- c("FMI" = "Fat Mass Index (kg/m²)", "LMI" = "Lean Mass Index (kg/m²)", "FM_trunk_quotient_limb" = "FM Trunk Quotient Limb (ratio)", "FM_android_quotient_gynoid" = "FM Android/Gynoid Quotient (ratio)", "appendicular_LMI" = "Appendicular LMI (kg/m²)", "percent_FM" = "Percent Fat Mass (%)", "VAT_mass" = "Visceral Adipose Tissue Mass (g)", "fitted_FMI" = "Fitted Fat Mass Index (kg/m^x)", "fitted_LMI" = "Fitted Lean Mass Index (kg/m^x)", "fitted_BMI" = "Fitted Body Mass Index (kg/m^x)", "fitted_ALMI" = "Fitted Appendicular LMI (kg/m^x)", "BMI" = "Body Mass Index (kg/m²)", "height" = "Height (cm)", "weight" = "Weight (kg)")
gender_map <- c("0" = "Female", "1" = "Male")
age_group_map <- c("children" = "Children", "adults" = "Adults")

#' Plot percentile curves
#'
#' `plot_percentile_curves` generates percentile curves for a specified body composition measurements
#' (e.g., Fat Mass Index, Lean Mass Index, Percent Fat Mass) across different ages,
#' stratified by gender and age group. It uses precomputed LMS (Lambda-Mu-Sigma) reference
#' data stored as CSV files and visualizes the curves for the 3%, 10%, 25%, 50%, 75%, 90%, and 97% percentiles.
#'
#' @param ref_data_path Character string specifying the path to the LMS reference CSV files.
#'   Default is `"LMS_data/"`.
#' @param age_group Character string specifying the age group. Must be `"children"` or `"adults"`.
#' @param measurement Character string specifying the measurement to plot. Should match a key in `measurement_map`.
#' @param gender Numeric value indicating gender: `0` for Female, `1` for Male.
#'
#' @return A `ggplot` object showing percentile curves for the selected measurement.
#'   If the reference file is missing, an empty plot with the title "No data available" is returned.
#'
#' @details
#' The function reads the LMS reference CSV corresponding to the selected age group, measurement,
#' and gender. It reshapes the data into long format for plotting, then uses `ggplot2` to create
#' the percentile curves. Labels for each percentile are displayed at the right end of the plot.
#'
#' @examples
#' \dontrun{
#' # Plot Percent Fat Mass for children, females
#' plot_percentile_curves(
#'   ref_data_path = "LMS_data/",
#'   age_group = "children",
#'   measurement = "percent_FM",
#'   gender = 0
#' )
#'
#' # Plot Lean Mass Index for adult, males
#' plot_percentile_curves(
#'   ref_data_path = "LMS_data/",
#'   age_group = "adults",
#'   measurement = "LMI",
#'   gender = 1
#' )
#' }
#'
plot_percentile_curves <- function(ref_data_path = "LMS_data/",
                                   age_group = "children",
                                   measurement = "percent_FM",
                                   gender = 0) {
  # Construct the LMS CSV filename
  LMS_data_filename <- paste0(ref_data_path, age_group, "_LMS_", measurement, "_gender", as.character(gender), ".csv")

  # Generate plot title
  title <- paste("--", age_group_map[age_group], "--", gender_map[as.character(gender)])

  if (file.exists(LMS_data_filename)) {
    data_long <- read.csv(LMS_data_filename) %>%
      dplyr::select(age, X3., X10., X25., X50., X75., X90., X97.) %>%
      dplyr::rename(
        p3  = X3.,
        p10 = X10.,
        p25 = X25.,
        p50 = X50.,
        p75 = X75.,
        p90 = X90.,
        p97 = X97.
      ) %>%
      tidyr::pivot_longer(
        cols = -age,
        names_to = "percentile",
        values_to = "measurement"
      )

    # Create percentile curves plot
    ggplot2::ggplot(data_long, aes(x = age, y = measurement, color = percentile)) +
      ggplot2::geom_line(linewidth = 0.2) +
      ggplot2::geom_text(
        data = data_long %>% dplyr::group_by(percentile) %>% dplyr::slice_max(age, n = 1),
        aes(label = label_map[percentile]),
        size = 6,
        hjust = -0.2
      ) +
      ggplot2::scale_color_manual(values = rep("#1F5DA0", 7)) +
      ggplot2::scale_x_continuous(
        breaks = pretty(data_long$age, n = 10),
        expand = expansion(mult = c(0, 0.1)),
        minor_breaks = waiver()
      ) +
      ggplot2::scale_y_continuous(
        breaks = pretty(data_long$measurement, n = 10),
        minor_breaks = waiver()
      ) +
      ggplot2::labs(
        title = title,
        x = "Age (years)",
        y = measurement_map[measurement]
      ) +
      ggplot2::theme_bw() +
      ggplot2::theme(
        panel.grid.minor = element_blank(),
        text = element_text(size = 24),
        plot.title = element_text(size = 24),
        panel.border = element_rect(fill = NA, colour = "black"),
        legend.position = "none",
        axis.title = element_text(size = 24),
        axis.text = element_text(size = 16),
        aspect.ratio = 1
      )
  } else {
    # Return empty plot if file not found
    ggplot2::ggplot() +
      ggplot2::labs(title = "No data available") +
      ggplot2::theme_bw() +
      ggplot2::theme(
        text = element_text(size = 24),
        plot.title = element_text(size = 24, hjust = 0.5),
        aspect.ratio = 1
      )
  }
}


#' Create histogram for body composition measurements
#'
#' `create_histogram` generates a histogram for a specified measurement, optionally filtered by
#' age group and gender. It can also return an empty plot if no data is provided.
#'
#' @param age_group Character string: "children" or "adults"
#' @param value Measurement to plot (must match a key in `measurement_map`)
#' @param gender Numeric: 0 = Female, 1 = Male
#' @param data Data frame containing the measurements and columns `age` and `gender`
#'
#' @return A `ggplot` histogram or an empty plot if no data available
create_histogram <- function(age_group = "children", value = "percent_FM", gender = 0, data = NULL) {
  
  if (!is.null(data)) {

    # Filter by gender
    if (!is.null(gender)) {
      data_filtered <- data %>% dplyr::filter(gender == gender)
    } else {
      data_filtered <- data
    }
    
    # Filter by age group
    if (!is.null(age_group)) {
      if (age_group == "children") {
        data_filtered <- data_filtered %>% dplyr::filter(age < 18)
      } else if (age_group == "adults") {
        data_filtered <- data_filtered %>% dplyr::filter(age >= 18)
      }
    }

  title <- paste("--", age_group_map[age_group], "--", gender_map[as.character(gender)])
  x_label <- measurement_map[value]

  # Plot
  data_filtered <- na.omit(data_filtered)
    
  if (!is.null(data_filtered) && nrow(data_filtered) > 0 && value %in% colnames(data_filtered)) {
    p <- ggplot2::ggplot(data_filtered, ggplot2::aes_string(x = value)) +
      ggplot2::geom_histogram(aes(y = ..density..), binwidth = 5, fill = "#289DBE", color = "white") +
      ggplot2::labs(title = title, x = x_label, y = "Density") +
      ggplot2::theme_bw() +
      ggplot2::theme(
        text = element_text(size = 24),
        plot.title = element_text(size = 24, hjust = 0.5),
        axis.title = element_text(size = 20),
        axis.text = element_text(size = 18),
        aspect.ratio = 1
      )
  } else {
    p <- ggplot2::ggplot() +
      ggplot2::labs(title = paste("No data for", title)) +
      ggplot2::theme_bw() +
      ggplot2::theme(
        text = element_text(size = 24),
        plot.title = element_text(size = 24, hjust = 0.5),
        aspect.ratio = 1
      )
  }
  }
  
  return(p)
}


#' Plot percentile curves with data points overlay
#'
#' `plot_percentile_with_points` overlays individual data points on top of the percentile curves
#' generated by `plot_percentile_curves`. It allows visual comparison of observed data with reference
#' percentile curves.
#'
#' @param ref_data_path Character: Path to LMS reference CSV files.
#' @param age_group Character: "children" or "adults".
#' @param measurement Character: Measurement name (must exist in `measurement_map`).
#' @param gender Numeric: 0 = Female, 1 = Male.
#' @param data Data frame containing columns `age`, `gender`, and the measurement variable.
#' @param point_size Numeric: Size of the points (default = 2).
#' @param point_alpha Numeric: Transparency of points (default = 0.6).
#' @param point_color Character: Color of the points (default = "black").
#'
#' @return A ggplot object showing percentile curves with overlaid data points.
#'   If reference data or observed data is missing, a fallback message is shown.
#'
#' @examples
#' \dontrun{
#' plot_percentile_with_points(
#'   ref_data_path = "LMS_data/",
#'   age_group = "children",
#'   measurement = "percent_FM",
#'   gender = 0,
#'   data = df
#' )
#' }
#'
plot_percentile_with_points <- function(ref_data_path = "LMS_data/",
                                        age_group = "children",
                                        measurement = "percent_FM",
                                        gender = 0,
                                        data = NULL) {
  
  base_plot <- plot_percentile_curves(
    ref_data_path = ref_data_path,
    age_group = age_group,
    measurement = measurement,
    gender = gender
  )

  # If data provided, filter for matching gender and age group
  if (!is.null(data) && measurement %in% colnames(data)) {
    data_filtered <- data %>%
      dplyr::filter(gender == gender) %>%
      dplyr::filter(if (age_group == "children") age < 18 else age >= 18) %>%
      dplyr::select(age, !!rlang::sym(measurement))
    
    # Overlay data points
    if (nrow(data_filtered) > 0) {
      base_plot <- base_plot +
        ggplot2::geom_point(
          data = data_filtered,
          aes(x = age, y = !!rlang::sym(measurement)),
          inherit.aes = FALSE,
          color = "#DD4132",
          size = 1,
          alpha = 0.8
        )
    } else {
      message("No matching data points to plot for the selected group.")
    }
  } else {
    message("No valid data provided or measurement column missing.")
  }

  return(base_plot)
}
