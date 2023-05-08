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

addResourcePath("assets", system.file("simpleInput","aggrid_nonreactive","assets", package = "dataGridsInShiny"))

# Define UI for application that draws a histogram
ui <- fluidPage(
	tags$head(tags$script(src= "assets/this_app.js")),

    # Application title
    titlePanel("Test Grid Input"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
        	# create tab panel for each grid
        	tabsetPanel(id = "tabs",
        		tabPanel("AG-Grid",dataGridsInShiny::aggridUI('aggrid-container'),),
        		tabPanel("gridXL", verbatimTextOutput("summary")),
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
           			"Send Data to DT"),
           DT::DTOutput("dt"),
           DT::DTOutput("dtsel"),
           width = 5                   #total width out of 12
        )
    )
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

# Define server logic required to draw a histogram
server <- function(input, output, session) {

	# this is a sample blank page with some prefilled column
	emptydf <- data.frame(
		local_row_number = c(1,2,3,4,5,6,7),
		po_row_id = c(4100, 4101, 4102, 4103, 4104, 4105, 4106),
		num_carton = NA,
		num_box = NA,
		num_bag = NA,
		num_piece = NA,
		supplier_pallet = c(1, 1, 2, 2, 3, 5, 6),
		purhase_price = c(1.0,1.0,1.0,1.0,1.0,1.0,1.0),
		done = c(TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE),
		p_date = c("2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20","2023-04-20"),
		note = NA
	)
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
		#print(input$tabs)
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
		}
	}) %>% bindEvent(input$load_custom_data2)

	output$dt <- DT::renderDT({
		req(input$griddata2)
		input$griddata2})

	output$dtsel <- DT::renderDT({
		req(input$griddata3)
		input$griddata3})

    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white',
             xlab = 'Waiting time to next eruption (in mins)',
             main = 'Histogram of waiting times')
    })
}

# Run the application
shinyApp(ui = ui, server = server)
