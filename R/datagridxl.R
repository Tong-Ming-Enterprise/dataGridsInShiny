
#' Prepare Data and Options for DataGridXL
#'
#' See sample app in package for example: `system.file("DataGridXL/nonreactive/app.R", package = "dataGridsInShiny")`
#'
#' @param data data.frame to show
#' @param options list of options according to DataGridXL documentation
#'
#' @return list
#' @export

datagridxl <- function(data, options = list()){
	stopifnot(is.data.frame(data))
	stopifnot(is.list(options))

	# Drop row names because these seem to cause problems
	rownames(data) <- NULL

	# Convert data.frame to rowwise list
	data <- apply(data, 1, as.list)

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
datagridxlUI <- function(id = "datagrid", width = "100%", height = "400px"){

	# Create basic html tag
	style <- htmltools::css(width = htmltools::validateCssUnit(width), height = htmltools::validateCssUnit(height))
	args <- list(id = id,
				 class = "datagridxlr",
				 style = style)
	grid <-do.call(htmltools::div, args)

	# Prepare dependency
	path <- system.file("DataGridXL", package = "dataGridsInShiny")
	deps <- htmltools::htmlDependency(
		name = "DataGridXL",
		version = "2.22.07.30",
		src = c(file = path),
		script = c("datagridxl2.js")
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

datagridxl_output_handler <- function(data, ...){
	browser()
	purrr::map_dfr(data, as.data.frame)
}

