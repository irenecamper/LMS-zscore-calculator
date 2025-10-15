# Global parameters
label_map <- c( p3 = "3 %", p10 = "10 %", p25 = "25 %", p50 = "50 %", p75 = "75 %", p90 = "90 %", p97 = "97 %" )
measurement_map <- c( "FMI" = "Fat Mass Index (kg/m²)", "LMI" = "Lean Mass Index (kg/m²)", "FM_trunk_quotient_limb" = "FM Trunk Quotient Limb (ratio)", "FM_android_quotient_gynoid" = "FM Android/Gynoid Quotient (ratio)", "appendicular_LMI" = "Appendicular LMI (kg/m²)", "percent_FM" = "Percent Fat Mass (%)", "VAT_mass" = "Visceral Adipose Tissue Mass (g)", "fitted_FMI" = "Fitted Fat Mass Index (kg/m^x)", "fitted_LMI" = "Fitted Lean Mass Index (kg/m^x)", "fitted_BMI" = "Fitted Body Mass Index (kg/m^x)", "fitted_ALMI" = "Fitted Appendicular LMI (kg/m^x)", "BMI" = "Body Mass Index (kg/m²)", "height" = "Height (cm)", "weight" = "Weight (kg)" )
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
      ggplot2::scale_color_manual(values = rep("blue", 7)) +
      ggplot2::scale_x_continuous(
        breaks = seq(min(data_long$age), max(data_long$age), by = (max(data_long$age) - min(data_long$age)) / 4),
        limits = c(min(data_long$age), max(data_long$age) + (max(data_long$age) - min(data_long$age)) / 8)
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
        aspect.ratio = 1 / 2
      )
    
  } else {
    # Return empty plot if file not found
    ggplot2::ggplot() +
      ggplot2::labs(title = "No data available") +
      ggplot2::theme_bw() +
      ggplot2::theme(
        text = element_text(size = 24),
        plot.title = element_text(size = 24, hjust = 0.5),
        aspect.ratio = 1 / 2
      )
  }
}
