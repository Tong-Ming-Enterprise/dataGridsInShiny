var aggrid
var gridOptions

// Define cell selection handler
function onCellSelected(event) {
  //console.log("onCellSelected")
  //console.log(event)
  //console.log(editedCell)
  // go thru each node and if its in editedRow select the row
  gridOptions.api.forEachNode(function(node) {
      //console.log(node)
      if (editedRow.includes(node.rowIndex)) {
          //console.log("selecting"+node.rowIndex)
          console.log(node)
          node.setSelected(true)
      }
  });
  console.log(event)
  // if checkbox selected we need to set it. ??
  if (event.source == "checkboxSelected") {
    //console.log("checkboxSelected")
    editedRow.push(event.rowIndex)
    //editedCell[event.rowIndex][0] = 1
  }
}

// this is where the AG-Grid is created in javascript
// type must match calling .R session$sendCustomMessage(type = "create-aggrid",
Shiny.addCustomMessageHandler(type = "create-aggrid", function(rgridOptions){
	//console.log(type)
	const gridContainer = document.querySelector("#aggrid-container");
	//console.log("in custom message handler")
	// gridOptions pass infrom R
	// adding javascript function event callback
	gridOptions = rgridOptions
	gridOptions.onCellValueChanged = onCellValueChanged
	gridOptions.onRowSelected = onCellSelected

	//console.log(gridOptions)
	//gridOptions.data = gridOptions.rowData;
	aggrid = new agGrid.Grid(gridContainer, gridOptions);
	//console.log(aggrid)
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

// this function can be user to change edited cell type from char back to int
function changeDataType(outdata) {
	console.log(outdata)
	return outdata
}

function sendGridData(){
	outData = []
	gridOptions.api.forEachNode((rowNode, index) => {
		outData.push(rowNode.data)
                    console.log('node ' + index + ' is in the grid');
                    console.log(rowNode.data)
    });

    // ag-grid will change edited value to text this will cause issue when sending data back into R
    // so need to change them to int. this will be case by case depend on what the origianl data is
    outData = changeDataType(outData)
    console.log(outData)
	// https://shiny.rstudio.com/articles/communicating-with-js.html
	// https://book.javascript-for-r.com/shiny-complete.html
	// variableName:inputHandlerName. variableName is griddata2 and inputHandler is defined in zzz.R call aggrid.griddata
	Shiny.setInputValue('griddata2:aggrid.griddata', outData);
	Shiny.setInputValue('unsaved_changes', false);

	var unsaved_warning_button = document.getElementById("unsaved_warning_button");
	unsaved_warning_button.style.visibility = "hidden";

	//aggrid.events.on('setcellvalues', sendChangeEvent); // start listening for changes again

}

var editedRow = []
// keep track of cell that has been updated. so we can keep track of which cell has been modified. but updating color still not
//working yet
//var editedCell = []

const editedBackgroundColor = 'cyan'
const errorBackgroundColor = 'red'
const tableHeader = ["local_row_number", "po_row_id", "num_carton", "num_box", "num_bag", "num_piece", "supplier_pallet"];
// Define column definitions


// Create ag-Grid table
const gridContainer = document.querySelector("#grid-container");

// clear list after creation
// clear editedRow
editedRow = []


// Define cell value changed event handler
function onCellValueChanged(event) {
  // Update the row data with the new value
  //console.log("onCellValueChanged")
  //console.log(event)
  editedRow.push(event.rowIndex)
  //console.log("edited "+editedRow)
  event.data[event.colDef.field] = event.newValue;
  //console.log(event.colDef.field)
  //editedCell[event.rowIndex][tableHeader.indexOf(event.colDef.field)] = 1
  //console.log(editedCell)

  // compare number aginst carton and pieces raise error if data is not valid
  // bag needs to compare against carton
  let errorFound = false
  if (event.colDef.field == 'num_bag') {
    if (Number(event.newValue) % event.data.num_carton != 0) {
      errorFound = true
      event.colDef.cellStyle = (p) =>
        p.rowIndex.toString() === event.node.id ? {'background-color': errorBackgroundColor} : {};

        event.api.refreshCells({
          force: true,
          columns: [event.column.getId()],
          rowNodes: [event.node]
        });
    }
  }
  if (event.colDef.field == 'num_box') {
    if (Number(event.newValue) % event.data.num_carton != 0) {
      errorFound = true
      event.colDef.cellStyle = (p) =>
        p.rowIndex.toString() === event.node.id ? {'background-color': errorBackgroundColor} : {};

        event.api.refreshCells({
          force: true,
          columns: [event.column.getId()],
          rowNodes: [event.node]
        });
    }
  }
  // https://stackoverflow.com/questions/62222534/ag-grid-change-cell-color-on-cell-value-change
  if (!errorFound) {
    if (event.oldValue !== event.newValue) {
      event.colDef.cellStyle = (p) =>
      p.rowIndex.toString() === event.node.id ? {'background-color': editedBackgroundColor} : {};

      event.api.refreshCells({
        force: true,
        columns: [event.column.getId()],
        rowNodes: [event.node]
      });
    }
  }
}

// handle output button click
function handleClick() {
  console.log("exporting")
  let items = [];
  gridOptions.api.forEachNode(function(node) {
      console.log(node.rowIndex)
      if (editedRow.includes(node.rowIndex)) {
          console.log("edited"+node.rowIndex)
          items.push(node.data);
      }
  });
  console.log(items)
  //const data = gridOptions.api.getSelectedNodes(); // or api.getDataAsExcel() for Excel format
  //console.log(data)
  const data2 = gridOptions.api.getSelectedRows(); // or api.getDataAsExcel() for Excel format
  console.log(data2)
  // loop thru editedRow and create new data from it?

  alert('Button clicked!');
}

