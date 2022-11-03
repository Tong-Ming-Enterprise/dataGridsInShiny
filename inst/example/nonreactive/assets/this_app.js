var grid;

Shiny.addCustomMessageHandler(type = "create-grid", function(message){
	grid = new DataGridXL("datagrid", message);
	grid.events.on('setcellvalues', sendChangeEvent);
	grid.events.on('setcellvalues', addBlankRowOnEdit);
});

// Note: we should really use grid.events.on('change', sendChangeEvent), but even
// though the documentation says this event exists, when I try to use it nothing happens.
// In a full app, I would thus probably need to subscribe to more than simply 'setchangevalues'.

function sendChangeEvent(gridEvent){
	console.log("change!");
	Shiny.setInputValue('unsaved_changes', true);

	var unsaved_warning_button = document.getElementById("unsaved_warning_button");
	unsaved_warning_button.style.visibility = "visible";

	grid.events.off('setcellvalues', sendChangeEvent); // only need to send first event
}

function sendGridData(){
	Shiny.setInputValue('griddata:datagridxlr.griddata', grid.getData());
	Shiny.setInputValue('unsaved_changes', false);

	var unsaved_warning_button = document.getElementById("unsaved_warning_button");
	unsaved_warning_button.style.visibility = "hidden";

	grid.events.on('setcellvalues', sendChangeEvent); // start listening for changes again

}

function addBlankRowOnEdit(gridEvent){
	// When user edits a cell, if it is in last row, add a blank row
	let numrow = grid.getData().length;
	let current_row = grid.getCellCursorPosition().y + 1;

	if(current_row == numrow)
		grid.insertEmptyRows();
}


