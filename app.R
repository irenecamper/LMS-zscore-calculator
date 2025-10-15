# Parameters ----
values <- c(
  "Fat Mass Index"                = "FMI",
  "Lean Mass Index"               = "LMI",
  "FM Trunk Quotient Limb"        = "FM_trunk_quotient_limb",
  "FM Android/Gynoid Quotient"    = "FM_android_quotient_gynoid",
  "Appendicular LMI"              = "appendicular_LMI",
  "Percent FM"                    = "percent_FM",
  "VAT Mass"                      = "VAT_mass",
  "Fitted FMI"                    = "fitted_FMI",
  "Fitted LMI"                    = "fitted_LMI",
  "Fitted BMI"                    = "fitted_BMI",
  "Fitted ALMI"                   = "fitted_ALMI",
  "BMI"                           = "BMI",
  "Height"                        = "height",
  "Weight"                        = "weight"
)

CHOICES <- list(
  value = values,
  age_group = c("Children" = "children", "Adults" = "adults"),
  gender = c("Male" = 1, "Female" = 0)
)

PRIMARY <- "#CCC5BD"

# UI ----

LEAD_percentile_curves_card <- bslib::navset_card_tab(
  height = 800,
  sidebar = sidebar(
    width = 200,
    open = TRUE,
    shiny::selectizeInput(
      "value", "Value",
      selected = "percent_FM",
      choices = CHOICES$value,
      multiple = FALSE,
      options = list(
        plugins = "remove_button",
        closeAfterSelect = TRUE
      )
    ),
    shiny::checkboxInput(
      "include_data",
      "Plot Holbaek data",
      value = TRUE
    )
  ),
  # Two tabs inside the main area
  bslib::nav_panel(
    id = "main_tabs",
    # First tab: percentile curves
    title = "Percentile Curves",
    bslib::layout_columns(
      col_widths = c(6, 6),
      bslib::card_body(shiny::plotOutput("percentile_plot_children_male", height = 600)),
      bslib::card_body(shiny::plotOutput("percentile_plot_children_female", height = 600)),
      bslib::card_body(shiny::plotOutput("percentile_plot_adults_male", height = 600)),
      bslib::card_body(shiny::plotOutput("percentile_plot_adults_female", height = 600))
    )
  ),
  # Second tab: histograms
  bslib::nav_panel(
    title = "Histograms",
    bslib::layout_columns(
      col_widths = c(6, 6),
      bslib::card_body(shiny::plotOutput("histogram_children_male", height = 600)),
      bslib::card_body(shiny::plotOutput("histogram_children_female", height = 600)),
      bslib::card_body(shiny::plotOutput("histogram_adults_male", height = 600)),
      bslib::card_body(shiny::plotOutput("histogram_adults_female", height = 600))
    )
  )
)


ui <- bslib::page_navbar(
  theme = bs_theme(
    preset = "shiny",
    "primary" = PRIMARY
  ),
  fillable = FALSE,
  title = "LEAD study reference data",
  nav_spacer(),
  bslib::nav_panel(
    "data play",
    class = "bslib-page-dashboard",
    layout_columns(
      col_widths = c(12),
      LEAD_percentile_curves_card
    )
  )
)

# SERVER ----

server <- function(input, output, session) {
  data <- shiny::reactive({
    if (input$include_data) {
      dxa_data
    } else {
      NULL
    }
  })

  ## plot rendering ---
  output$percentile_plot_children_male <- shiny::renderPlot({
    plot <- create_plot(age_group = "children", value = input$value, gender = 0, include_data = input$include_data, data = dxa_data)
    plot
  })

  output$percentile_plot_children_female <- shiny::renderPlot({
    plot <- create_plot(age_group = "children", value = input$value, gender = 1, include_data = input$include_data, data = dxa_data)
    plot
  })

  output$percentile_plot_adults_male <- shiny::renderPlot({
    plot <- create_plot(age_group = "adults", value = input$value, gender = 0, include_data = input$include_data, data = dxa_data)
    plot
  })

  output$percentile_plot_adults_female <- shiny::renderPlot({
    plot <- create_plot(age_group = "adults", value = input$value, gender = 1, include_data = input$include_data, data = dxa_data)
    plot
  })

  output$histogram_children_male <- shiny::renderPlot({
    plot <- create_histogram(age_group = "children", value = input$value, gender = 0, include_data = input$include_data, data = dxa_data)
    plot
  })

  output$histogram_children_female <- shiny::renderPlot({
    create_histogram(age_group = "children", value = input$value, gender = 1, include_data = input$include_data, data = dxa_data)
  })

  output$histogram_adults_male <- shiny::renderPlot({
    create_histogram(age_group = "adults", value = input$value, gender = 0, include_data = input$include_data, data = dxa_data)
  })

  output$histogram_adults_female <- shiny::renderPlot({
    create_histogram(age_group = "adults", value = input$value, gender = 1, include_data = input$include_data, data = dxa_data)
  })


  ## table rendering ---
}
