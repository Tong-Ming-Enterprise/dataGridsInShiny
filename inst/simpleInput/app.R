#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(gridlayout)
devtools::load_all(".")

addResourcePath("assetsag", system.file("simpleInput","aggrid_nonreactive","assets", package = "dataGridsInShiny"))
addResourcePath("assetsxl", system.file("simpleInput","gridxl_nonreactive","assets", package = "dataGridsInShiny"))

# Define UI for application that draws a histogram
ui <- fluidPage(
	tags$head(tags$script(src= "assetsag/this_app.js")),
	tags$head(tags$script(src= "assetsxl/this_app.js")),

    # Application title
    titlePanel("Test Grid Input"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
        	# create tab panel for each grid
        	tabsetPanel(id = "tabs",
        		tabPanel("AG-Grid",dataGridsInShiny::aggridUI('aggrid-container')),
        		tabPanel("gridXL", dataGridsInShiny::datagridxlUI()),
        		tabPanel("excel", tableOutput("table"))
        	),
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30),
        	width = 7                  # total width out of 12
        ),

        # Show a plot of the generated distribution
        mainPanel(
           actionButton("load_custom_data", "Load custom data", class = "btn-primary"),
           actionButton("load_custom_data2", "Load custom data 2", class = "btn-primary"),
           tags$button(class = "btn btn-primary",
           			onClick = "sendGridData()",       #this javascript function is found in this_app.js link in tag above
           			"Send AG Data to DT"),
           tags$button(class = "btn btn-primary",
           			onClick = "sendGridXLData()",       #this javascript function is found in this_app.js link in tag above
           			"Send XL Data to DT"),
           DT::DTOutput("dt"),
           DT::DTOutput("dtsel"),
           width = 5                   #total width out of 12
        )
    )
)

sampledf <- data.frame(
	local_row_number = c(1,2,3,4,5,6,7,8,9,10),
	pallet_id = c(81,82,83,84,85,86,87,88,89,90),
	incoming_shipment_id = c(21, 21, 21, 21, 21, 21, 21, 21, 21, 21),
	old_location = c("收貨區","收貨區","收貨區","收貨區","收貨區","收貨區","收貨區","收貨區","收貨區","收貨區"),
	new_location = c(0, 0, 0, 0, 0, 0, 0, 16, 18, 0),
	note = c("1","1","1","1","1","1","1","1","1","1")
)
sampledf2 <- data.frame(
	local_row_number = c(1,2,3,4,5,6,7,8,9,10),
	pallet_id = c(91,92,93,94,95,96,97,98,99,100),
	incoming_shipment_id = c(44, 44, 44, 44, 44, 44, 44, 44, 44, 44),
	old_location = c("收貨區","收貨區","收貨區","收貨區","收貨區","收貨區","收貨區","收貨區","收貨區","收貨區"),
	new_location = c(2, 4, 6, 0, 0, 0, 0, 16, 18, 0),
	note = c("1","1","1","1","1","1","1","1","1","1")
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

	# this is a sample blank page with some prefilled column
	emptydf <- data.frame(
		local_row_number = c(1,2,3,4,5,6,7),
		incoming_shipment_id = c(4100, 4101, 4102, 4103, 4104, 4105, 4106),
		old_location = c("2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20"),
		new_location = NA,
		note = NA
	)
	columnDefs <- list(
		list(field = "local_row_number", hide = TRUE),
		list(headerName = "Pallet ID #", field = "pallet_id", checkboxSelection = TRUE, headerCheckboxSelection = TRUE, width = 140),
		list(headerName = "shipment ID", field = "incoming_shipment_id", width = 120),
		list(headerName = "Old Location", field = 'old_location', width = 120),
		list(headerName = "Select", field = "sel", editable = TRUE, singleClickEdit = TRUE, cellEditor = 'agSelectCellEditor', cellEditorParams = list(values = list('E', 'F' )), width = 80),
		list(headerName = "New Location", field = "new_location", editable = TRUE, singleClickEdit = TRUE, width = 120),
		list(headerName = "Note", field = "note", editable = TRUE, singleClickEdit = TRUE, cellEditor = 'agLargeTextCellEditor', cellEditorPopup = TRUE, cellEditorParams = list(maxLength = 100,rows = 10, cols = 50))
	)
	gridOptionsInitial <- list(
		columnDefs = columnDefs,
		rowData = list(),
		rowSelection = "multiple",
		pagination = TRUE,
		paginationPageSize = 7
		#editType = 'fullRow'
	)
	# this will show initial blank table
	session$sendCustomMessage(type = "create-aggrid-receiving",
							  message = dataGridsInShiny::aggrid(gridOptionsInitial))

	observe({
		print(input$tabs)
		purrOutput <- sampledf %>% purrr::transpose()
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

		# load data depend on which tab was selected
		if (input$tabs == "AG-Grid") {
			mtype = "update-aggrid-receiving"
			session$sendCustomMessage(type = mtype,
									  message = dataGridsInShiny::aggrid(gridOptions))
		} else if (input$tabs == "gridXL") {
			print("calling custommessage for gridXL")
			options <- list(rowHeaderLabelPrefix = "test ",
							rowHeaderWidth = 100,
							allowEditCells = FALSE)
			session$sendCustomMessage(type = "create-grid",
									  message = dataGridsInShiny::datagridxl(sampledf, options))
		}
		}) %>% bindEvent(input$load_custom_data)

	observe({
		#print(input$tabs)
		purrOutput <- sampledf2 %>% purrr::transpose()
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

		# load data depend on which tab was selected
		if (input$tabs == "AG-Grid") {
			mtype = "update-aggrid-receiving"
			session$sendCustomMessage(type = mtype,
									  message = dataGridsInShiny::aggrid(gridOptions))
		} else if (input$tabs == "gridXL") {
			print("calling custommessage for gridXL")
			options <- list(rowHeaderLabelPrefix = "test ",
							rowHeaderWidth = 100,
							allowEditCells = FALSE)
			session$sendCustomMessage(type = "create-grid",
									  message = dataGridsInShiny::datagridxl(sampledf2, options))
		}
	}) %>% bindEvent(input$load_custom_data2)

	output$dt <- DT::renderDT({
		req(input$griddata2)
		input$griddata2})

	output$dtsel <- DT::renderDT({
		req(input$griddata3)
		input$griddata3})

}

# Run the application
shinyApp(ui = ui, server = server)
