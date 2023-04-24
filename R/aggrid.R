
#' Prepare Data and Options for ag-grid
#'
#' See sample app in package for example: `system.file("aggrid/nonreactive/app.R", package = "dataGridsInShiny")`
#'
#' @param options list of options according to ag-grid documentation
#'
#' @return list
#' @export

aggrid <- function(options = list()){
	stopifnot(is.list(options))

	#browser()
	# Drop row names because these seem to cause problems
	#rownames(data) <- NULL
	data <- options$rowData

	# Convert data.frame to rowwise list
	#data <- apply(options$rowData, 1, as.list)

	# Add options to this list...
	c(list(data = data), options)
}


#' Prepare UI tag and Dependency for Grid.
#'
#' @param id This is used exactly once, in the JavaScript creating the grid
#' @param width The width of the input, e.g. `400px`, or `100%`; see `htmltools::validateCssUnit()`.
#' @param height The height of the input, e.g. `400px`, or `100%`; see `htmltools::validateCssUnit()`.
#'
#' @return Placeholder HTML for grid.
#' @export
aggridUI <- function(id = "grid-container", width = "100%", height = "400px"){

	#browser()
	# Create basic html tag
	style <- htmltools::css(width = htmltools::validateCssUnit(width), height = htmltools::validateCssUnit(height))
	args <- list(id = id,
				 class = "ag-theme-alpine",     #<- this is the css theme ag-theme-alpine
				 style = style)
	grid <-do.call(htmltools::div, args)		#<- this is creating the div container for aggrid

	# Prepare dependency
	path <- system.file("aggrid", package = "dataGridsInShiny")
	deps <- htmltools::htmlDependency(
		name = "ag-grid-community",
		version = "28.2.1",
		src = c(file = path),
		script = c("ag-grid-community.min.js"),
		# for some reason unpkg.com url from index.html give 404 error but this link is ok ???
		#head = HTML('<link rel="stylesheet" href="https://unpkg.com/ag-grid-community@latest/dist/styles/ag-grid.min.css">
		#			 <link rel="stylesheet" href="https://unpkg.com/ag-grid-community@latest/dist/styles/ag-theme-alpine.min.css">')
		#head = HTML('<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ag-grid-community@29.2.0/styles/ag-grid.css">
        #             <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ag-grid-community@latest/styles/ag-theme-alpine.min.css">')
		head = HTML('<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ag-grid-community@29.2.0/styles/ag-grid.css">
		             <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ag-grid-community@latest/styles/ag-theme-alpine.min.css">')
	)

	# Attach dependency and return
	htmltools::attachDependencies(grid, deps)
}

#' Data Grid Output Handler
#'
#' Transform exported data into data.frame.
#'
#'
#' @param data the JSON data
#' @param ... other unused parameters
#'
#' @return a data.frame
#' @export

aggrid_output_handler <- function(data, ...){
	browser()
	purrr::map_dfr(data, as.data.frame)
}

