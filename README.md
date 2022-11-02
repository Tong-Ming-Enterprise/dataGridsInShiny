
# datagridxlr

<!-- badges: start -->
<!-- badges: end -->

The goal of datagridxlr is to show how to use the Javascript package [datagrdXL](https://www.datagridxl.com) in a Shiny app.  Mostly this is so I can practice what I learned in [JavaScript for R](https://book.javascript-for-r.com).

Because we don't actually want every cell change being sent back to the server, and because we don't want the user to lose their changes because the entire grid re-creates itself unexpectedly, we don't make the grid reactive.  That is, it is neither in `output$` nor `input$`.  The grid is controlled through an adhoc JS file that must be written for each app.  In other words, you must write JS to use this grid in your Shiny app.

## Installation

You can install the development version of datagridxlr from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("michael-dewar/datagridxlr")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
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
```
You also need the accompanying JS code:
```
var grid;

Shiny.addCustomMessageHandler(type = "create-grid", function(message){
	grid = new DataGridXL("datagrid", message);
});

sendGridData = function(){
	Shiny.setInputValue('griddata:datagridxlr.griddata', grid.getData());
};
```
