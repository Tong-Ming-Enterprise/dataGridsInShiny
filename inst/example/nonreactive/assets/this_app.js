var grid;

Shiny.addCustomMessageHandler(type = "create-grid", function(message){
	grid = new DataGridXL("datagrid", message);
});

sendGridData = function(){
	Shiny.setInputValue('griddata:datagridxlr.griddata', grid.getData());
};
