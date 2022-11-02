.onLoad <- function(libname, pkgname){
	shiny::registerInputHandler("datagridxl.output", datagridxl_output_handler)
}
