library(shiny)
devtools::load_all(".")

addResourcePath("assets", system.file("aggrid","nonreactive","assets", package = "dataGridsInShiny"))

ui <- fluidPage(
	tags$head(tags$script(src= "assets/this_app.js")),
	actionButton("create_grid_mtcars", "Create ag-Grid with custom", class = "btn-primary"),
	actionButton("create_grid_iris", "Create ag-Grid with iris", class = "btn-primary"),
	tags$button(class = "btn btn-primary",
				onClick = "sendGridData()",
				"Send Data to DT"),
	tags$button(class = "btn btn-danger",
				id = "unsaved_warning_button",
				style = 'visibility:hidden;',
				"You have unsaved changes!"),
	# textOutput("unsaved_warning"),
	dataGridsInShiny::aggridUI(),
	DT::DTOutput("dt")

)

server <- function(input, output, session) {
	observe({
		options <- list(rowHeaderLabelPrefix = "test ",
						rowHeaderWidth = 300,
						allowEditCells = FALSE)
		#browser()
		columnDefs <- list(
			list(headerName = "Row #", field = "local_row_number", width = 80),
			list(headerName = "PO", field = "po_row_id", width = 120),
			list(headerName = "Carton", field = "num_carton", width = 120),
			list(headerName = "Box", field = "num_box", width = 120),
			list(headerName = "Bag", field = "num_bag", width = 120),
			list(headerName = "Piece", field = "num_piece", width = 120),
			list(headerName = "Pallet", field = "supplier_pallet", width = 120)
		)
		rowData = list(
			list( local_row_number = 1, po_row_id = 100, num_carton = 2, num_box = 0, num_bag = 0, num_piece = 1000, supplier_pallet = 1 ),
			list( local_row_number = 2, po_row_id = 101, num_carton = 4, num_box = 0, num_bag = 0, num_piece = 2000, supplier_pallet = 1 ),
			list( local_row_number = 3, po_row_id = 102, num_carton = 6, num_box = 0, num_bag = 0, num_piece = 3000, supplier_pallet = 2 ),
			list( local_row_number = 4, po_row_id = 103, num_carton = 8, num_box = 0, num_bag = 0, num_piece = 4000, supplier_pallet = 2 ),
			list( local_row_number = 5, po_row_id = 104, num_carton = 10, num_box = 0, num_bag = 0, num_piece = 5000, supplier_pallet = 3 ),
			list( local_row_number = 6, po_row_id = 105, num_carton = 12, num_box = 0, num_bag = 48, num_piece = 6000, supplier_pallet = 5 )
		)
		# Grid options
		gridOptions <- list(
			columnDefs = columnDefs,
			rowData = rowData,
			rowSelection = "multiple"
		)

		session$sendCustomMessage(type = "create-aggrid",
								  message = dataGridsInShiny::aggrid(gridOptions))}) %>%
		bindEvent(input$create_grid_mtcars)

	observe({
		options <- list(singleClickEdit = TRUE)
		columnDefs <- list(
			list(headerName = "MPG", field = "Sepal.length", width = 80),
			list(headerName = "CYL", field = "Sepal.width", width = 150),
			list(headerName = "DISP", field = "Petal.length", width = 80),
			list(headerName = "HP", field = "Petal.width", width = 120)
		)
		# Grid options
		gridOptions <- list(
			columnDefs = columnDefs,
			rowData = iris,
			rowSelection = "multiple"
		)
		session$sendCustomMessage(type = "create-aggrid",
								  message = dataGridsInShiny::aggrid(iris, options))}) %>%
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

