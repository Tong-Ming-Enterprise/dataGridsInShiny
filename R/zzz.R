.onLoad <- function(libname, pkgname){
	shiny::registerInputHandler("datagridxlr.griddata", datagridxl_output_handler)
}

.onDetach <- function(libpath){
	shiny::removeInputHandler("datagridxlr.griddata")
}
