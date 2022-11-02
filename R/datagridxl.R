#' @export
datagridxl <- function(data, options = list()){
	stopifnot(is.data.frame(data))
	stopifnot(is.list(options))

	# drop row names
	rownames(data) <- NULL

	# Convert data.frame to rowwise list
	data <- apply(data, 1, as.list)

	# Later add options to this list...
	c(list(data = data), options)
}

#' @export
datagridxlOutput <- function(id, width = "100%", height = "400px"){

	# Create basic html tag
	style <- htmltools::css(width = validateCssUnit(width), height = validateCssUnit(height))
	args <- list(id = id,
				 class = "datagridxlr",
				 style = style)
	grid <-do.call(div, args)

	# Prepare dependency
	path <- system.file(package = "datagridxlr")
	deps <- htmltools::htmlDependency(
		name = "datagridxlr",
		version = packageVersion("datagridxlr"),
		src = c(file = path),
		script = c("datagridxlr.js", "datagridxl2.js"),
		stylesheet = "datagridxlr.css"
	)

	# Attach dependency and return
	htmltools::attachDependencies(grid, deps)
}

#' @export
renderDatagridxl <- function(expr, env = parent.frame(), quoted = FALSE){

	func <- shiny::exprToFunction(expr, env, quoted)

	function(){
		func()
	}
}

# create handler
datagridxl_output_handler <- function(data, ...){
	purrr::map_dfr(data, as.data.frame)
}

