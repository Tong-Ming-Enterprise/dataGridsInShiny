library(shiny)
library(tidyverse)
library(rhandsontable)
devtools::load_all(".")

addResourcePath("assets", system.file("rHansonTable","nonreactive","assets", package = "dataGridsInShiny"))

ui <- fluidPage(
	tags$head(tags$script(src= "assets/this_app.js")),
	# pickaday.js lib use as pop up to choose a date
	tags$head(tags$script(src = "https://cdn.jsdelivr.net/npm/pikaday/pikaday.js")),
	tags$link(rel="stylesheet", type="text/css", href="https://cdn.jsdelivr.net/npm/pikaday/css/pikaday.css"),

	# create_custom_aggrid is trigger in the server
	actionButton("update_custom_aggrid", "Update custom ag-Grid", class = "btn-primary"),
	actionButton("update_custom_aggrid2", "Update custom ag-Grid 2", class = "btn-primary"),
	actionButton("hide_column", "Hide grid column", class = "btn-primary"),
	tags$button(class = "btn btn-primary",
				onClick = "sendGridData()",       #this javascript function is found in this_app.js link in tag above
				"Send Data to DT"),
	tags$button(class = "btn btn-danger",
				id = "unsaved_warning_button",
				style = 'visibility:hidden;',
				"You have unsaved changes!"),
	# textOutput("unsaved_warning"),
	rHandsontableOutput("rhtable"),
	#dataGridsInShiny::aggridUI('aggrid-container'),
	DT::DTOutput("dt"),
	DT::DTOutput("dtsel")
)

sampledf <- data.frame(
	local_row_number = c(1,2,3,4,5,6,7,8,9,10),
	po_row_id = c(100, 101, 102, 103, 104, 105, 106, 107, 108, 109),
	num_carton = c(2, 4, 6, 8, 10, 12, 14, 16, 18, 20),
	num_box = c(0, 0, 0, 0, 0, 0, 0, 16, 18, 0),
	num_bag = c(0, 0, 0, 0, 0, 48, 28, 0, 0, 0),
	num_piece = c(1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000),
	supplier_pallet = c(1, 1, 2, 2, 3, 5, 6, 8, 9, 11),
	purhase_price = c(1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0),
	done = c(TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE),
	p_date = c("2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20"),
	note = c("1","1","1","1","1","1","1","1","1","1")
)

sampledf2 <- data.frame(
	local_row_number = c(1,2,3,4,5,6,7,8,9,10),
	po_row_id = c(4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109),
	num_carton = c(82, 84, 86, 88, 90, 12, 14, 16, 18, 20),
	num_box = c(2, 4, 6, 0, 0, 0, 0, 16, 18, 0),
	num_bag = c(0, 0, 0, 0, 0, 48, 28, 0, 0, 0),
	num_piece = c(21000, 22000, 23000, 24000, 25000, 26000, 27000, 28000, 29000, 210000),
	supplier_pallet = c(1, 1, 2, 2, 3, 5, 6, 8, 9, 11),
	purhase_price = c(1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0),
	done = c(TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE),
	p_date = c("2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20"),
	note = c("1","1","1","1","1","1","1","1","1","1")
)


# drop down
#https://stackoverflow.com/questions/57634100/is-there-a-way-to-have-different-dropdown-options-for-different-rows-in-an-rhand
carOptions <- c(NA_character_, "tires", "wipers", "headlights")
DF = data.frame(Row = c(1,2,3,4,5,6,7,8,9,10),
				po_row_id = c(4100, 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109),
				num_carton = c(82, 84, 86, 88, 90, 12, 14, 16, 18, 20),
				num_box = c(2, 4, 6, 0, 0, 0, 0, 16, 18, 0),
				num_bag = c(0, 0, 0, 0, 0, 48, 28, 0, 0, 0),
				num_piece = c(21000, 22000, 23000, 24000, 25000, 26000, 27000, 28000, 29000, 210000),
				supplier_pallet = c(1, 1, 2, 2, 3, 5, 6, 8, 9, 11),
				done = c(TRUE,TRUE,FALSE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE),
				p_date = c("2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20"),
				note = c("1","1","1","1","1","1","1","1","1","1"),
				sel = c(NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_,NA_character_),
				character = LETTERS[1:10],
				factor = factor(letters[1:10], levels = letters[10:1],
								ordered = TRUE),
				factor_allow = factor(letters[1:10], levels = letters[10:1],
									  ordered = TRUE),
				date = seq(from = Sys.Date(), by = "days", length.out = 10),
				stringsAsFactors = FALSE)

# https://stackoverflow.com/questions/54184050/turning-a-dataframe-into-named-list
#purrOutput <- sampledf %>% purrr::transpose()

server <- function(input, output, session) {

	# type = 'numericColumn' still return char when cell has been edited MYL 04-25-2023
	# adding javascript numberParser to verify if number is entered. NaN is return. TODO but on export NaN needs to be change or R will not like it.
	# if agSelectCelEditor is set after the agLargeTextEditor it will not render properly instead the aglargeTextCellEditor will be render but behave different MYL 04-27-2023

	columnDefs <- list(
		list(headerName = "Row #", field = "local_row_number", checkboxSelection = TRUE, headerCheckboxSelection = TRUE, width = 110),
		list(headerName = "PO", field = "po_row_id", width = 120),
		list(headerName = "Carton", field = "num_carton", editable = TRUE, singleClickEdit = TRUE, filter = 'agNumberColumnFilter', width = 120),
		list(headerName = "Box", field = "num_box", editable = TRUE, singleClickEdit = TRUE, width = 120),
		list(headerName = "Bag", field = "num_bag", editable = TRUE, singleClickEdit = TRUE, width = 120),
		list(headerName = "Piece", field = "num_piece", editable = TRUE, singleClickEdit = TRUE, width = 120),
		list(headerName = "Pallet", field = "supplier_pallet", width = 120),
		list(headerName = "Price", field = 'purhase_price', cellClass = 'currencyFormat', editable = TRUE, singleClickEdit = TRUE, width =120),
		list(headerName = "Done", field = "done", cellClass = 'booleanType', editable = TRUE, singleClickEdit = TRUE, width = 80),
		list(headerName = "Date", field = 'p_date', cellClass = 'dateType', editable = TRUE, singleClickEdit = TRUE, cellEditor = 'DatePicker', cellEditorPopup = TRUE, width = 240),
		list(headerName = "Select", field = "sel", editable = TRUE, singleClickEdit = TRUE, cellEditor = 'agSelectCellEditor', cellEditorParams = list(values = list('English', 'Spanish', 'French', 'Portuguese', '(other)'))),
		list(headerName = "Note", field = "note", editable = TRUE, singleClickEdit = TRUE, cellEditor = 'agLargeTextCellEditor', cellEditorPopup = TRUE, cellEditorParams = list(maxLength = 100,rows = 10, cols = 50))
	)

	# default date format is MM/DD/YYYY so if date is that format no need to declare hot_col
	output$rhtable <- renderRHandsontable({rhandsontable(DF, width = 800, height = 300)  %>%
										   hot_col("po_row_id", readOnly = TRUE) %>%
										   hot_col("supplier_pallet", readOnly = TRUE) %>%
										   hot_col("sel", type = "dropdown", source = carOptions) %>%
										   hot_col("p_date", dateFormat = "YYYY-MM-DD", type = "date")
		})


	observe({
		#gridOptions <- c(gridOptionsInitial, rowData = purrOutput)
		# Grid options
		gridOptions <- list(
			columnDefs = columnDefs,
			rowData = purrOutput,  #rowData,
			rowSelection = "multiple",
			pagination = TRUE,
			paginationPageSize = 7
			#editType = 'fullRow'
		)
		# send custom message to JS.
		# the columnDef, gridOptions and data are sent to javascript
		session$sendCustomMessage(type = "update-aggrid-receiving",
								  message = dataGridsInShiny::aggrid(gridOptions))}) %>% bindEvent(input$update_custom_aggrid)

	observe({
		# Grid options
		colList <- list(
			"num_box",
			"num_bag"
		)
		session$sendCustomMessage(type = "hide_column",
								  message = dataGridsInShiny::aggrid(colList))}) %>%
		bindEvent(input$hide_column)

	output$dt <- DT::renderDT({
		req(input$griddata2)
		input$griddata2})

	output$dtsel <- DT::renderDT({
		req(input$griddata3)
		input$griddata3})

	# output$unsaved_warning <- shiny::renderText({
	# 	req(input$unsaved_changes)
	# 	if(input$unsaved_changes)
	# 		return("You have unsaved changes!")
	# 	else
	# 		return()
	# })
}

shinyApp(ui, server)

