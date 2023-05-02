# call by server in /inst/aggrid/nonreactive/app.R server
# to send a customMessage that will be handle by javascript handler in /inst/aggrid/nonreactive/assets/this_app.js
# dataGridsInShiny::aggrid(gridOptions)

#' Prepare Data and gridOptions for ag-grid
#'
#' See sample app in package for example: `system.file("aggrid/nonreactive/app.R", package = "dataGridsInShiny", "done")`
#'
#' @param options list of options according to ag-grid documentation with rowData as part of the structure
#'
#' @return list
#' @export

aggrid <- function(options = list()){
	stopifnot(is.list(options))
	# no format massaging for ag-grid so just return the options as it was pass it. other package might need more work.
	options
}

# called by UI in /inst/aggrid/nonreactive/app.R
# sample call dataGridsInShiny::aggridUI('aggrid-container')
# css theme link added here below

#' Prepare UI tag and Dependency for agGrid.
#'
#' @param id This is used exactly once, in the JavaScript creating the grid. its a div label
#' @param width The width of the input, e.g. `400px`, or `100%`; see `htmltools::validateCssUnit()`.
#' @param height The height of the input, e.g. `400px`, or `100%`; see `htmltools::validateCssUnit()`.
#'
#' @return Placeholder HTML for grid.
#' @export
aggridUI <- function(id = "aggrid-container", width = "100%", height = "400px"){

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
#' Transform exported data into data.frame. Convert null and NaN to NA_integer_ or dataFrame will not like it
#'
#'
#' @param data the JSON data
#' @param ... other unused parameters
#'
#' @return a data.frame
#' @export
# this has to be declare in /R/zzz.R
aggrid_output_handler <- function(data, ...){
	# list of field name to check for non integer
	listInt <- list("num_box","num_bag","num_carton","num_piece")
	#https://stackoverflow.com/questions/13450360/how-to-validate-date-in-r#:~:text=Simple%20way%3A,%27t%20correct!%22)%20%7D
	listDate <- list("p_date")
	listChar <- list("note")
	if (length(data)) {
		for (i in 1:length(data)) {
			for (name in names(data[[i]])) {
				# need to check both null and NaN
				if ((is.null(data[[i]][[name]]) || (is.nan(data[[i]][[name]]))) && (name %in% listInt)) {
					print(name)
					print(data[[i]][[name]])
					data[[i]][[name]] = NA_integer_
				}

			}
		}
	}

	purrr::map_dfr(data, as.data.frame)
}

