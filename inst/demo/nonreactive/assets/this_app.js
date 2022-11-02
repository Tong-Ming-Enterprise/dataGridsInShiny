var grid;

Shiny.addCustomMessageHandler(type = "create-grid", function(message){
	console.log(message);
	var big_dummy = DataGridXL.createDummyData(2000,500);
	var some_data = [
		[1, 2, 3],
		["a", "b", "c"],
		["d", "e", "f"]
		];
	//grid = new DataGridXL("datagrid", {data: big_dummy});
	grid = new DataGridXL("datagrid", message);
});

sendGridData = function(){
	Shiny.setInputValue('griddata:datagridxl.output', grid.getData());
	console.log("Sent!");
};
