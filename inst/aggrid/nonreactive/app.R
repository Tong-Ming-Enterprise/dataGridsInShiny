library(shiny)
devtools::load_all(".")

addResourcePath("assets", system.file("aggrid","nonreactive","assets", package = "dataGridsInShiny"))

ui <- fluidPage(
	tags$head(tags$script(src= "assets/this_app.js")),
	# create_custom_aggrid is trigger in the server
	actionButton("create_custom_aggrid", "Create custom ag-Grid", class = "btn-primary"),
	tags$button(class = "btn btn-primary",
				onClick = "sendGridData()",       #this javascript function is found in this_app.js link in tag above
				"Send Data to DT"),
	tags$button(class = "btn btn-danger",
				id = "unsaved_warning_button",
				style = 'visibility:hidden;',
				"You have unsaved changes!"),
	# textOutput("unsaved_warning"),
	dataGridsInShiny::aggridUI('aggrid-container'),
	DT::DTOutput("dt")

)

server <- function(input, output, session) {
	rowData = list(
		list( local_row_number = 1, po_row_id = 100, num_carton = 2, num_box = 2, num_bag = 0, num_piece = 1000, supplier_pallet = 1 ),
		list( local_row_number = 2, po_row_id = 101, num_carton = 4, num_box = 0, num_bag = 0, num_piece = 2000, supplier_pallet = 1 ),
		list( local_row_number = 3, po_row_id = 102, num_carton = 6, num_box = 0, num_bag = 0, num_piece = 3000, supplier_pallet = 2 ),
		list( local_row_number = 4, po_row_id = 103, num_carton = 8, num_box = 0, num_bag = 0, num_piece = 4000, supplier_pallet = 2 ),
		list( local_row_number = 5, po_row_id = 104, num_carton = 10, num_box = 0, num_bag = 0, num_piece = 5000, supplier_pallet = 3 ),
		list( local_row_number = 6, po_row_id = 105, num_carton = 12, num_box = 0, num_bag = 48, num_piece = 6000, supplier_pallet = 5 )
	)
	columnDefs <- list(
		list(headerName = "Row #", field = "local_row_number", checkboxSelection = TRUE, width = 80),
		list(headerName = "PO", field = "po_row_id", width = 120),
		list(headerName = "Carton", field = "num_carton", editable = TRUE, singleClickEdit = TRUE, width = 120),
		list(headerName = "Box", field = "num_box", editable = TRUE, singleClickEdit = TRUE, width = 120),
		list(headerName = "Bag", field = "num_bag", editable = TRUE, singleClickEdit = TRUE, width = 120),
		list(headerName = "Piece", field = "num_piece", editable = TRUE, singleClickEdit = TRUE, width = 120),
		list(headerName = "Pallet", field = "supplier_pallet", width = 120)
	)
	observe({

		# Grid options
		gridOptions <- list(
			columnDefs = columnDefs,
			rowData = rowData,
			rowSelection = "multiple"
		)
		# send custom message to JS.
		# the columnDef, gridOptions and data are sent to javascript
		session$sendCustomMessage(type = "create-aggrid",
								  message = dataGridsInShiny::aggrid(gridOptions))}) %>%
		bindEvent(input$create_custom_aggrid)

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

