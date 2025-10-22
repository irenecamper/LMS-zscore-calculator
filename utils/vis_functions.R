# Global parameters
label_map <- c(p3 = "3 %", p10 = "10 %", p25 = "25 %", p50 = "50 %", p75 = "75 %", p90 = "90 %", p97 = "97 %")
measurement_map <- c(
  FMI = "Fat Mass Index (kg/m²)", LMI = "Lean Mass Index (kg/m²)",
  FM_trunk_quotient_limb = "FM Trunk Quotient Limb (ratio)",
  FM_android_quotient_gynoid = "FM Android/Gynoid Quotient (ratio)",
  appendicular_LMI = "Appendicular LMI (kg/m²)", percent_FM = "Percent Fat Mass (%)",
  VAT_mass = "Visceral Adipose Tissue Mass (g)",
  fitted_FMI = "Fitted Fat Mass Index (kg/m^x)", fitted_LMI = "Fitted Lean Mass Index (kg/m^x)",
  fitted_BMI = "Fitted Body Mass Index (kg/m^x)", fitted_ALMI = "Fitted Appendicular LMI (kg/m^x)",
  BMI = "Body Mass Index (kg/m²)", height = "Height (cm)", weight = "Weight (kg)"
)
gender_map <- c("0" = "Female", "1" = "Male")
age_group_map <- c(children = "Children", adults = "Adults")

# Base theme for all plots
base_theme <- ggplot2::theme_bw() +
  ggplot2::theme(
    text = element_text(size = 24),
    plot.title = element_text(size = 24, hjust = 0.5),
    axis.title = element_text(size = 20),
    axis.text = element_text(size = 18),
    aspect.ratio = 1
  )

plot_percentile_curves <- function(ref_data_path = "LMS_data/",
                                   age_group = "children",
                                   measurement = "percent_FM",
                                   gender_value = 0) {
  
  LMS_data_filename <- paste0(ref_data_path, age_group, "_LMS_", measurement, "_gender", gender_value, ".csv")
  title <- paste("--", age_group_map[age_group], "--", gender_map[as.character(gender_value)])

  if (!file.exists(LMS_data_filename)) {
    return(ggplot2::ggplot() +
             ggplot2::labs(title = "No data available") +
             base_theme)
  }

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

    ggplot2::ggplot(data_long, aes(x = age, y = measurement, color = percentile)) +
    ggplot2::geom_line(linewidth = 0.2) +
    ggplot2::geom_text(
      data = data_long %>% dplyr::group_by(percentile) %>% dplyr::slice_max(age, n = 1),
      aes(label = label_map[percentile]),
      size = 6,
      hjust = -0.2
    ) +
    ggplot2::scale_color_manual(values = rep("#1F5DA0", 7)) +
    ggplot2::scale_x_continuous(breaks = pretty(data_long$age, n = 10), expand = expansion(mult = c(0, 0.1))) +
    ggplot2::scale_y_continuous(breaks = pretty(data_long$measurement, n = 10)) +
    ggplot2::labs(title = title, x = "Age (years)", y = measurement_map[measurement]) +
    base_theme +
    ggplot2::theme(legend.position = "none")
}

# --- Create histogram ---
create_histogram <- function(age_group = "children", value = "percent_FM", gender_value = 0, data = NULL) {
  if (is.null(data)) return(ggplot2::ggplot() + ggplot2::labs(title = "No data available") + base_theme)

  data_filtered <- data %>%
    dplyr::filter(gender == gender_value,
                  (age_group == "children" & age < 18) | (age_group == "adults" & age >= 18)) %>%
    na.omit()

  title <- paste("--", age_group_map[age_group], "--", gender_map[as.character(gender_value)])
  x_label <- measurement_map[value]

  if (nrow(data_filtered) == 0 || !(value %in% colnames(data_filtered))) {
    return(ggplot2::ggplot() + ggplot2::labs(title = paste("No data for", title)) + base_theme)
  }

  ggplot2::ggplot(data_filtered, ggplot2::aes_string(x = value)) +
    ggplot2::geom_histogram(aes(y = ..density..), binwidth = 5, fill = "#289DBE", color = "white") +
    ggplot2::labs(title = title, x = x_label, y = "Density") +
    base_theme
}

# --- Plot percentile curves with data points overlay ---
plot_percentile_with_points <- function(ref_data_path = "LMS_data/",
                                        age_group = "children",
                                        measurement = "percent_FM",
                                        gender_value = 0,
                                        data = NULL) {

  base_plot <- plot_percentile_curves(ref_data_path, age_group, measurement, gender_value)

  if (!is.null(data) && measurement %in% colnames(data)) {
    y_col <- rlang::sym(measurement)
    data_filtered <- data %>%
      dplyr::filter(gender == gender_value,
                    (age_group == "children" & age < 18) | (age_group == "adults" & age >= 18)) %>%
      dplyr::select(age, !!y_col)

    if (nrow(data_filtered) > 0) {
      base_plot <- base_plot +
        ggplot2::geom_point(data = data_filtered, aes(x = age, y = !!y_col),
                            inherit.aes = FALSE, color = "#DD4132", size = 1, alpha = 0.8)
    } else {
      message("No matching data points to plot for the selected group.")
    }
  } else {
    message("No valid data provided or measurement column missing.")
  }

  base_plot
}
