
# Plot with ggplot2
create_plot <- function(age_group = "children", value = "percent_FM", gender = 0) {

  reference_filename <- paste0("../data/", age_group, "_LMS_", value, "_gender", as.character(gender), ".csv")[1]

  gender_label <- ifelse(gender == 0, "female", "male")

  title <- paste(value, "--", age_group, "--", gender_label)
  label_map <- c(
    p3  = "3 %",
    p10 = "10 %",
    p25 = "25 %",
    p50 = "50 %",
    p75 = "75 %",
    p90 = "90 %",
    p97 = "97 %"
  )
  # Read the CSV file
  if (file.exists(reference_filename)) {
    data_long <- read.csv(reference_filename) %>%
      select(age, X3., X10., X25., X50., X75., X90., X97.) %>%
      dplyr::rename(
        p3  = X3.,
        p10 = X10.,
        p25 = X25.,
        p50 = X50.,
        p75 = X75.,
        p90 = X90.,
        p97 = X97.
     ) %>%
      pivot_longer(
      cols = -age,
      names_to = "percentile",
      values_to = "value"
    )

    # Plot with ggplot2
    ggplot(data_long, aes(x = age, y = value, color = percentile)) +
      geom_line(size = 0.2) +
      geom_text(
        data = data_long %>% group_by(percentile) %>% slice_max(age, n = 1),
        aes(label = label_map[percentile]),  # use mapped labels
        size = 6
      ) +
      scale_color_manual(
        values = rep("blue", 7)  # all lines same color
      ) +
      scale_x_continuous(breaks = seq(min(data_long$age), max(data_long$age), by = 4)) +
      labs(
      title = title,
      x = "age (years)",
      y = value
    ) +
    theme_bw() +
    theme(
      panel.grid.minor = element_blank(),
      text = element_text(size = 24),
      plot.title = element_text(size = 24),
      panel.border = element_rect(fill = NA, colour = "black"),
      legend.position = "none",
      axis.title = element_text(size = 24),
      axis.text = element_text(size = 24),
      axis.title.y = element_blank()
    )
  } else {
  
  # Display empty plot
  ggplot() +
    labs(
      title = "No data available"
    ) +
    theme_bw() +
    theme(
      text = element_text(size = 24),
      plot.title = element_text(size = 24, hjust = 0.5)
    )
  }
}
