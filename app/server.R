server <- function(input, output, session) {

  ## plot rendering ---
  output$percentile_plot <- shiny::renderPlot({
    plot <- create_plot(age_group = input$age_group, value = input$value, gender = as.numeric(input$gender))
    plot
  })

  ## table rendering ---
  
}