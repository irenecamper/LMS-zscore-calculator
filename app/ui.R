LEAD_percentile_curves_card <- bslib::navset_card_tab(
  sidebar = sidebar(
    width = 160,
    open = TRUE,
    shiny::selectizeInput(
      "value", "Value",
      selected = CHOICES$value[1],
      choices = CHOICES$value,
      multiple = FALSE,
      options = list(
        plugins = "remove_button",
        closeAfterSelect = TRUE
      )
    ),
    shiny::selectizeInput(
      "age_group", "Age group",
      selected = CHOICES$age_group[1],
      choices = CHOICES$age_group,
      multiple = FALSE,
      options = list(
        plugins = "remove_button",
        closeAfterSelect = TRUE
      )
    ),
    shiny::selectizeInput(
      "gender", "Gender",
      selected = CHOICES$gender[1],
      choices = CHOICES$gender,
      multiple = FALSE,
      options = list(
        plugins = "remove_button",
        closeAfterSelect = TRUE
      )
    )
  ),
  bslib::nav_panel(
    title = "Percentile reference curves",
    full_screen = TRUE,
    id = "percentile_plot_nav",
    bslib::card_body(shiny::plotOutput("percentile_plot"))
  )
)

ui <- bslib::page_navbar(
  theme = bs_theme(
    preset = "shiny",
    "primary" = PRIMARY
  ),
  fillable = FALSE,
  title = "data play",
  nav_spacer(),
  bslib::nav_panel(
    "percentile curves",
    class = "bslib-page-dashboard",
    layout_columns(
      col_widths = c(12),
      LEAD_percentile_curves_card # ,
      # prs_main_card,
      # forest_plot_card,
      # heatmap_plot_card, #
      # raw_card
    )
  )
)