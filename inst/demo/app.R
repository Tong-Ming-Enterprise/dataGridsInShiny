library(shiny)

ui <- fluidPage(
	datagridxlOutput("grid")
)

server <- function(input, output, session) {
  output$grid <- renderDatagridxl({
  	mtcars %>%
  		tibble::as_tibble(rownames = "rownames") %>%
  		head() %>%
  		datagridxl()
  })
}

shinyApp(ui, server)
