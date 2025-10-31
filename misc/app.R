# --- Load libraries ------------------------------------------------------------
library(shiny)
library(bslib)
library(ggplot2)

# --- Load DXA data and external functions --------------------------------------
source("utils/vis_functions.R")
source("utils/load_data.R")
source("utils/load_data_dxa.R")

# --- Parameters ----------------------------------------------------------------
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

# --- UI ------------------------------------------------------------------------
LEAD_percentile_curves_card <- bslib::navset_card_tab(
  height = 1600,
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
    )
  ),
  bslib::nav_panel(
    id = "main_tabs",
    title = "Percentile Curves",
    bslib::layout_columns(
      col_widths = c(6, 6),
      bslib::card_body(shiny::plotOutput("percentile_plot_children_male", height = 800)),
      bslib::card_body(shiny::plotOutput("percentile_plot_children_female", height = 800)),
      bslib::card_body(shiny::plotOutput("percentile_plot_adults_male", height = 800)),
      bslib::card_body(shiny::plotOutput("percentile_plot_adults_female", height = 800))
    )
  ),
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

# --- SERVER --------------------------------------------------------------------

server <- function(input, output, session) {
  data <- shiny::reactive({
    if (input$include_data) {
      dxa_data
    } else {
      NULL
    }
  })

  ## --- plot rendering ---
  output$percentile_plot_children_male <- shiny::renderPlot({
    plot_percentile_with_points(
      ref_data_path = "LMS_data/",
      age_group = "children",
      measurement = input$value,
      gender_value =0,
      data = dxa_data
    )

  })

  output$percentile_plot_children_female <- shiny::renderPlot({
    plot_percentile_with_points(
      ref_data_path = "LMS_data/",
      age_group = "children",
      measurement = input$value,
      gender_value =1,
      data = dxa_data
    )
  })

  output$percentile_plot_adults_male <- shiny::renderPlot({
    plot_percentile_with_points(
      ref_data_path = "LMS_data/",
      age_group = "adults",
      measurement = input$value,
      gender_value =0,
      data = dxa_data
    )
  })

  output$percentile_plot_adults_female <- shiny::renderPlot({
    plot_percentile_with_points(
      ref_data_path = "LMS_data/",
      age_group = "adults",
      measurement = input$value,
      gender_value =1,
      data = dxa_data
    )
  })

  output$histogram_children_male <- shiny::renderPlot({
    create_histogram(
      age_group = "children",
      value = input$value,
      gender_value =0,
      data = dxa_data
    )
  })

  output$histogram_children_female <- shiny::renderPlot({
    create_histogram(
      age_group = "children",
      value = input$value,
      gender_value =1,
      data = dxa_data
    )
  })


  output$histogram_adults_male <- shiny::renderPlot({
    create_histogram(
      age_group = "adults",
      value = input$value,
      gender_value =0,
      data = dxa_data
    )
  })

  output$histogram_adults_female <- shiny::renderPlot({
    create_histogram(
      age_group = "adults",
      value = input$value,
      gender_value =1,
      data = dxa_data
    )
  })

  ## --- table rendering ---
}


shinyApp(ui, server)