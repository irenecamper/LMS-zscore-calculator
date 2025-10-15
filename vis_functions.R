# --- Parameters ------------------------------------------------------------

# Label mapping
label_map <- c(
  p3  = "3 %",
  p10 = "10 %",
  p25 = "25 %",
  p50 = "50 %",
  p75 = "75 %",
  p90 = "90 %",
  p97 = "97 %"
)

# Measurement mapping
value_map <- c(
  "FMI"                        = "Fat Mass Index (kg/m²)",
  "LMI"                        = "Lean Mass Index (kg/m²)",
  "FM_trunk_quotient_limb"     = "FM Trunk Quotient Limb (ratio)",
  "FM_android_quotient_gynoid" = "FM Android/Gynoid Quotient (ratio)",
  "appendicular_LMI"           = "Appendicular LMI (kg/m²)",
  "percent_FM"                 = "Percent Fat Mass (%)",
  "VAT_mass"                   = "Visceral Adipose Tissue Mass (g)",
  "fitted_FMI"                 = "Fitted Fat Mass Index (kg/m^x)",
  "fitted_LMI"                 = "Fitted Lean Mass Index (kg/m^x)",
  "fitted_BMI"                 = "Fitted Body Mass Index (kg/m^x)",
  "fitted_ALMI"                = "Fitted Appendicular LMI (kg/m^x)",
  "BMI"                        = "Body Mass Index (kg/m²)",
  "height"                     = "Height (cm)",
  "weight"                     = "Weight (kg)"
)

# Gender mapping
gender_map <- c("0" = "Female", "1" = "Male")

# Age group mapping
age_group_map <- c("children" = "Children", "adults" = "Adults")


## Plot ...
create_percentile_curves_plot <- function(ref_data_path = "../LMS_data/", age_group = "children", value = "percent_FM", gender = 0) {

  LMS_data_filename <- paste0(ref_data_path, age_group, "_LMS_", value, "_gender", as.character(gender), ".csv")
  
  title <- paste("--", age_group_map[age_group], "--", gender_map[as.character(gender)])

  # Read the CSV file
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
      values_to = "value"
    )

    # Plot the percentile curves
    ggplot2::ggplot(data_long, aes(x = age, y = value, color = percentile)) +
      ggplot2::geom_line(linewidth = 0.2) +
      ggplot2::geom_text(
        data = data_long %>% group_by(percentile) %>% slice_max(age, n = 1),
        aes(label = label_map[percentile]),  # use mapped labels
        size = 6,
        hjust = -0.2
      ) +
      ggplot2::scale_color_manual(
        values = rep("blue", 7)  # all lines same color
      ) +
      ggplot2::scale_x_continuous(breaks = seq(min(data_long$age), max(data_long$age), by = (max(data_long$age) - min(data_long$age))/4),
                         limits = c(min(data_long$age), max(data_long$age) + (max(data_long$age) - min(data_long$age))/8)) +
      ggplot2::labs(
      title = title,
      x = "Age (years)",
      y = value_map[value],
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
      # axis.title.y = element_blank(),
      aspect.ratio = 1/2
    )
  } else {
  # Display empty plot
  ggplot2::ggplot() +
    ggplot2::labs(
      title = "No data available"
    ) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      text = element_text(size = 24),
      plot.title = element_text(size = 24, hjust = 0.5),
      aspect.ratio = 1/2
    )
  }
}