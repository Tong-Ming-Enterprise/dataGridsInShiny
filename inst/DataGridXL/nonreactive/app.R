library(shiny)
devtools::load_all(".")

addResourcePath("assets", system.file("DataGridXL","nonreactive","assets", package = "dataGridsInShiny"))

ui <- fluidPage(
	tags$head(tags$script(src= "assets/this_app.js")),
	actionButton("create_grid_mtcars", "Create Grid with mtcars", class = "btn-primary"),
	actionButton("create_grid_iris", "Create Grid with iris", class = "btn-primary"),
	tags$button(class = "btn btn-primary",
				onClick = "sendGridData()",
				"Send Data to DT"),
	tags$button(class = "btn btn-danger",
				id = "unsaved_warning_button",
				style = 'visibility:hidden;',
				"You have unsaved changes!"),
	# textOutput("unsaved_warning"),
	dataGridsInShiny::datagridxlUI(),
	DT::DTOutput("dt")

)

server <- function(input, output, session) {
	observe({
		options <- list(rowHeaderLabelPrefix = "test ",
						rowHeaderWidth = 300,
						allowEditCells = FALSE)
		session$sendCustomMessage(type = "create-grid",
								  message = dataGridsInShiny::datagridxl(mtcars, options))}) %>%
		bindEvent(input$create_grid_mtcars)

	observe({
		session$sendCustomMessage(type = "create-grid",
								  message = dataGridsInShiny::datagridxl(iris))}) %>%
		bindEvent(input$create_grid_iris)

	output$dt <- DT::renderDT({
		req(input$griddata)
		input$griddata})

	# output$unsaved_warning <- shiny::renderText({
	# 	req(input$unsaved_changes)
	# 	if(input$unsaved_changes)
	# 		return("You have unsaved changes!")
	# 	else
	# 		return()
	# })
}

shinyApp(ui, server)

