# --- Prepare long-format data and detect outliers ---
dxa_long <- dxa_data %>%
  tidyr::pivot_longer(
    cols = c(percent_FM, FMI, LMI, BMI, height, weight),
    names_to = "measurement",
    values_to = "value"
  ) %>%
  mutate(gender = factor(gender, levels = c(0, 1), labels = c("Male", "Female"))) %>%
  group_by(measurement, gender) %>%
  mutate(
    Q1 = quantile(value, 0.25, na.rm = TRUE),
    Q3 = quantile(value, 0.75, na.rm = TRUE),
    IQR = Q3 - Q1,
    is_outlier = value < (Q1 - 1.5 * IQR) | value > (Q3 + 1.5 * IQR)
  ) %>%
  ungroup()

# --- Plot: Violin + Points + Outlier Labels ---
ggplot(dxa_long, aes(x = gender, y = value, color = gender)) +
  geom_violin(
    trim = FALSE,
    draw_quantiles = c(0.25, 0.5, 0.75),
    position = position_dodge(width = 1)
  ) +
  geom_point(
    position = position_jitterdodge(seed = 1, dodge.width = 1, jitter.width = 0.2),
    size = 0.8,
    alpha = 0.7
  ) +
  ggrepel::geom_label_repel(
    data = subset(dxa_long, is_outlier),
    aes(label = paste0("PATID = ", PATID)),
    size = 2,
    max.overlaps = 20
  ) +
  labs(
    x = "Gender",
    y = "Measurement Value",
    color = "Gender",
    caption = "Outliers labeled by PATID"
  ) +
  scale_color_manual(values = c("Male" = "#4C72B0", "Female" = "#DD4132")) +
  theme_bw() +
  theme(
    panel.grid.minor = element_blank(),
    text = element_text(size = 10),
    axis.text.y = element_text(angle = 90),
    panel.border = element_rect(fill = NA, colour = "black"),
    strip.background = element_rect(fill = NA, colour = NA),
    strip.text = element_text(hjust = 1, vjust = 0.5, face = "bold"),
    legend.position = "none",
    legend.title = element_blank(),
    aspect.ratio = 1
  ) +
  facet_wrap(~measurement, scales = "free_y", ncol = 3)

