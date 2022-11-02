library(shiny)

addResourcePath("assets", system.file("example/nonreactive/assets", package = "datagridxlr"))

ui <- fluidPage(
	tags$head(tags$script(src= "assets/this_app.js")),
	actionButton("create_grid_mtcars", "Create Grid with mtcars", class = "btn-primary"),
	actionButton("create_grid_iris", "Create Grid with iris", class = "btn-primary"),
	tags$button(class = "btn btn-primary",
				onClick = "sendGridData()",
				"Send Data to DT"),
	datagridxlr::datagridxlUI(),
	DT::DTOutput("dt")

)

server <- function(input, output, session) {
	observe({
		options <- list(rowHeaderLabelPrefix = "test ",
						rowHeaderWidth = 300,
						allowEditCells = FALSE)
		session$sendCustomMessage(type = "create-grid",
								  message = datagridxlr::datagridxl(mtcars, options))}) %>%
		bindEvent(input$create_grid_mtcars)

	observe({
		session$sendCustomMessage(type = "create-grid",
								  message = datagridxlr::datagridxl(iris))}) %>%
		bindEvent(input$create_grid_iris)

	output$dt <- DT::renderDT({
		req(input$griddata)
		input$griddata})
}

shinyApp(ui, server)

