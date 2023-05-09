#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(tidyr)
library(dplyr)
library(shiny)
library(stringr)
library(gridlayout)
library(rhandsontable)
library(excelR)
devtools::load_all(".")

addResourcePath("assetsag", system.file("simpleInput","aggrid_nonreactive","assets", package = "dataGridsInShiny"))
addResourcePath("assetsxl", system.file("simpleInput","gridxl_nonreactive","assets", package = "dataGridsInShiny"))

# https://swechhya.github.io/excelR/

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
        		tabPanel("gridXL", dataGridsInShiny::datagridxlUI()),
        		tabPanel("AG-Grid",dataGridsInShiny::aggridUI('aggrid-container')),
        		tabPanel("rHandsOn",rHandsontableOutput("rhtable")),
        		tabPanel("excelR", excelOutput("excelRtable"))
        	),
            #sliderInput("bins",
            #            "Number of bins:",
            #            min = 1,
            #            max = 50,
            #            value = 30),
        	width = 7                  # total width out of 12
        ),

        # Show a plot of the generated distribution
        mainPanel(
           actionButton("load_custom_data", "Load custom data", class = "btn-primary"),
           actionButton("load_custom_data2", "Load custom data 2", class = "btn-primary"),
           tags$button(class = "btn btn-primary",
           			onClick = "sendGridData()",         #this javascript function is found in this_app.js link in tag above
           			"Send AG Data to DT"),
           tags$button(class = "btn btn-primary",
           			onClick = "sendGridXLData()",       #this javascript function is found in this_app.js link in tag above
           			"Send XL Data to DT"),
           actionButton("send_rhandson_data", "send rHandsOn to DT", class = "btn-primary"),
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
	sel = c("F","F","F","F","F","F","F","F","F","F"),
	new_location = c("0", "0", "0", "0", "0", "0", "0", "16", "18", "0"),
	note = c("1","1","1","1","1","1","1","1","1","1")
)
sampledf2 <- data.frame(
	local_row_number = c(1,2,3,4,5,6,7,8,9,10),
	pallet_id = c(91,92,93,94,95,96,97,98,99,100),
	incoming_shipment_id = c(44, 44, 44, 44, 44, 44, 44, 44, 44, 44),
	old_location = c("收貨區","收貨區","收貨區","收貨區","收貨區","收貨區","收貨區","收貨區","收貨區","收貨區"),
	sel = c("F","F","F","F","F","F","F","F","F","F"),
	new_location = c("2", "4", "6", "0", "0", "0", "0", "16", "18", "0"),
	note = c("1","1","1","1","1","1","1","1","1","1")
)
# this is a sample blank page with type specify by NA_... so far only rHandsOnTable use this type in empty table other use
# columndef to define type for the column

emptydf <- data.frame(
	local_row_number = c(1,2,3,4,5),
	pallet_id = NA_integer_,
	incoming_shipment_id = NA_integer_,
	old_location = NA_character_,
	sel = NA,
	new_location = NA_character_,
	note = NA_character_
)

# define for excelR
columns = data.frame(title = c('','Pallet ID #', 'shipment ID', 'Old Location', 'Select', 'New Location', 'Note'),
					 width = c(80, 140, 120, 120, 80, 120, 80),
					 type = c('text', 'text', 'text', 'text',  'dropdown', 'text', 'text'),
					 source = I(list(0,0,0,0,c('E','F'),0,0))
					 )

# define for rHandsOnTable
locationOptions <- c(NA_character_, "E", "F")
newlocal <- c("0111","0212","0313","0414")

# Define server logic required to draw a histogram
server <- function(input, output, session) {

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
	options <- list(allowEditCells = TRUE,
					allowSort = TRUE)
	session$sendCustomMessage(type = "create-grid",
							  message = dataGridsInShiny::datagridxl(emptydf, options))

	session$sendCustomMessage(type = "create-aggrid-receiving",
							  message = dataGridsInShiny::aggrid(gridOptionsInitial))

	output$rhtable <- renderRHandsontable({rhandsontable(emptydf, width = "100%", height = 400)  %>%
			hot_col("local_row_number", readOnly = TRUE, format = "0.") %>%
			hot_col("pallet_id", readOnly = TRUE, format = "0.") %>%
			hot_col("incoming_shipment_id", readOnly = TRUE, format = "0.") %>%
			hot_col("old_location", readOnly = TRUE) %>%
			hot_col("sel", type = "dropdown", source = locationOptions) %>%
			hot_col("new_location",type = "autocomplete", source = newlocal,
					strict = FALSE)
	})

	output$excelRtable <- renderExcel(excelTable(data = head(emptydf), columns = columns ))

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
							allowEditCells = TRUE,
							allowSort = TRUE)
			session$sendCustomMessage(type = "create-grid",
									  message = dataGridsInShiny::datagridxl(sampledf, options))
		} else if (input$tabs == "rHandsOn") {
			print("calling load custommessage for rHandsOn")
			output$rhtable <- renderRHandsontable({rhandsontable(sampledf, width = "100%", height = "100%")  %>%
					hot_col("local_row_number", readOnly = TRUE, format = "0.") %>%
					hot_col("pallet_id", readOnly = TRUE, format = "0.") %>%
					hot_col("incoming_shipment_id", readOnly = TRUE, format = "0.") %>%
					hot_col("old_location", readOnly = TRUE) %>%
					hot_col("sel", type = "dropdown", source = locationOptions) %>%
					hot_col("new_location",type = "autocomplete", source = newlocal,
							strict = FALSE)
			})
		} else if (input$tabs == "excelR") {
			print("calling load custommessage for excelR")
			output$excelRtable <- renderExcel(excelTable(data = head(sampledf), columns = columns ))
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
		} else if (input$tabs == "rHandsOn") {
			print("calling load custommessage for rHandsOn")
			output$rhtable <- renderRHandsontable({rhandsontable(sampledf2, width = "100%", height = "100%")  %>%
					hot_col("local_row_number", readOnly = TRUE) %>%
					hot_col("pallet_id", readOnly = TRUE) %>%
					hot_col("incoming_shipment_id", readOnly = TRUE) %>%
					hot_col("old_location", readOnly = TRUE) %>%
					hot_col("sel", type = "dropdown", source = locationOptions) %>%
					hot_col("new_location",type = "autocomplete", source = newlocal,
							strict = FALSE)
			})
		} else if (input$tabs == "excelR") {
			print("calling load custommessage for excelR")
			output$excelRtable <- renderExcel(excelTable(data = head(sampledf2), columns = columns ))
		}
	}) %>% bindEvent(input$load_custom_data2)

	observe({
		# pure R code for rHandsOnTable wrapper

		# send data depend on which tab was selected
		if (input$tabs == "rHandsOn") {
			print("calling custommessage for rHandsOn")
			test_df = hot_to_r(input$rhtable)

			# https://stackoverflow.com/questions/53118271/difference-between-paste-str-c-str-join-stri-join-stri-c-stri-pa
			# unite needs library(tidyverse) need to set na.rm = TRUE to ignore NA
			test_df <- test_df %>%
				       unite(mynew_location, sel, new_location, sep = "", remove = FALSE, na.rm = TRUE)
			# needs library(stringi)
			#test_df$mynew_locaiton <- stri_join(test_df$sel,test_df$new_location)

			# use library(stringr) auto ignore NA
			test_df <- test_df %>% mutate(
				mynewc_location = str_c(sel, new_location)
			)
			print(test_df)
			output$dt <- DT::renderDT({
				req(test_df)
				test_df})
			#user_data_frame <- fromJSON(output$rhtable$x$data)
			#print(user_data_frame)
		}
	}) %>% bindEvent(input$send_rhandson_data)

	output$dt <- DT::renderDT({
		req(input$griddata2)
		input$griddata2})

	output$dtsel <- DT::renderDT({
		req(input$griddata3)
		input$griddata3})

}

# Run the application
shinyApp(ui = ui, server = server)
