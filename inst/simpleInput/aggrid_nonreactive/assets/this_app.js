//import "../../../../node_modules/ag-grid-autocomplete-editor/dist/main.css";
//import { AutocompleteSelectCellEditor } from "ag-grid-autocomplete-editor";

var aggrid
var gridOptions
showCol = false
editedRow = []

const editedBackgroundColor = 'cyan'
const errorBackgroundColor = 'red'
const tableHeader = ["local_row_number", "po_row_id", "num_carton", "num_box", "num_bag", "num_piece", "supplier_pallet", "purhase_price"];

// https://stackblitz.com/edit/ag-grid-autocomplete-editor?file=index.js
// https://www.npmjs.com/package/ag-grid-autocomplete-editor
// npm install --save ag-grid-autocomplete-editor

const selectData = [
  { value: 0, label: "E0111" },
  { value: 1, label: "E0112" },
  { value: 2, label: "E0113" },
  { value: 3, label: "E0211" },
  { value: 4, label: "E0211" },
  { value: 5, label: "E0311" },
  { value: 6, label: "E0411" },
  { value: 7, label: "F0111" },
  { value: 8, label: "F0112" },
  { value: 9, label: "F0113" },
  { value: 10, label: "F0211" },
  { value: 11, label: "F0212" },
  { value: 12, label: "F0311" },
  { value: 13, label: "F0411" },
  { value: 14, label: "F0512" },
  { value: 15, label: "F0611" }
];

// Define cell selection handler
function onCellSelected(event) {
  console.log("onCellSelected")
  console.log(event)
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
  // if checkbox selected we need to set it. ?? only work in pure html not sure why
  if (event.source == "checkboxSelected") {
    //console.log("checkboxSelected")
    editedRow.push(event.rowIndex)
    //editedCell[event.rowIndex][0] = 1
  }
}

// this will change the type back to int for data that has been edited and returned as char
function numberParser(params) {
  return Number(params.newValue);
}

// Three step to add custom CheckboxRenderer to a column
// 1. declare CheckboxRenderer
// 2. assigned checkboxRenderer to the columnDefs
// 3. add CheckboxRenderer to gridOptions
//----------------------- CheckboxRenderer --------------------------------------------
//https://blog.ag-grid.com/binding-boolean-values-to-checkboxes-in-ag-grid/
function CheckboxRenderer() {}

CheckboxRenderer.prototype.init = function(params) {
  this.params = params;

  this.eGui = document.createElement('input');
  this.eGui.type = 'checkbox';
  this.eGui.checked = params.value;

  this.checkedHandler = this.checkedHandler.bind(this);
  this.eGui.addEventListener('click', this.checkedHandler);
}

CheckboxRenderer.prototype.checkedHandler = function(e) {
  let checked = e.target.checked;
  let colId = this.params.column.colId;
  this.params.node.setDataValue(colId, checked);
}

CheckboxRenderer.prototype.getGui = function(params) {
  return this.eGui;
}

CheckboxRenderer.prototype.destroy = function(params) {
  this.eGui.removeEventListener('click', this.checkedHandler);
}
//----------------------- CheckboxRenderer --------------------------------------------


// this is where the AG-Grid is created using javascript
// this is called by the server once and not bind to a button
// type must match calling .R session$sendCustomMessage(type = "create-aggrid-receiving",
Shiny.addCustomMessageHandler(type = "create-aggrid-receiving", function(rgridOptions){
	//console.log(type)
	const gridContainer = document.querySelector("#aggrid-container");
	//console.log("in custom message handler")
	// gridOptions pass infrom R
	// adding javascript function event callback
	if (gridOptions == null) {
		gridOptions = rgridOptions
		console.log(gridOptions)
		gridOptions.onCellValueChanged = onCellValueChanged
		gridOptions.onRowSelected = onCellSelected

		// make column numeric input
		// the order are from declaration of columnDefs foud in app.R
		newcolDef = rgridOptions.columnDefs
		//console.log(newcolDef)
		//newcolDef[2].valueParser = numberParser
		//newcolDef[3].valueParser = numberParser
		//newcolDef[4].valueParser = numberParser
		//newcolDef[5].valueParser = numberParser
		// https://www.ag-grid.com/javascript-data-grid/value-setters/

		// 2. assigned checkboxRenderer to the columnDefs
		// from https://blog.ag-grid.com/binding-boolean-values-to-checkboxes-in-ag-grid/
		//newcolDef[8].cellRenderer = 'checkboxRenderer'

		gridOptions.columnDefs = newcolDef

		// 3. add CheckboxRenderer to gridOptions
		// from https://blog.ag-grid.com/binding-boolean-values-to-checkboxes-in-ag-grid/
		gridOptions.components = {
			checkboxRenderer: CheckboxRenderer
		}
		aggrid = new agGrid.Grid(gridContainer, gridOptions);
	}
});

// update rowdata for the table
Shiny.addCustomMessageHandler(type = "update-aggrid-receiving", function(rgridOptions){
	if (aggrid && gridOptions) {
		gridOptions.api.setRowData(rgridOptions.rowData)
		loadData = rgridOptions.rowData
		console.log(loadData)
	}
});


Shiny.addCustomMessageHandler(type = "hide_column", function(colList){
	console.log(colList)
	// loop thru list
	colList.forEach((acol) => {
		console.log(showCol?"Show ":"Hide "+acol)
		gridOptions.columnApi.setColumnVisible(acol, showCol)
	})
	showCol = !showCol
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

// sending data to R variable using Shiny.setInputValue()
function sendGridData(using_lib = "AGGrid"){
	outData = []
	if (using_lib == "AGGrid") {
		//console.log("handling AGGrid output")
		selRow = gridOptions.api.getSelectedRows()
		// looping thru all the nodes
		gridOptions.api.forEachNode((rowNode, index) => {
			rowNode.data.mynewlocation = !isNaN(rowNode.data.new_location)
			                             ?(rowNode.data.sel+rowNode.data.new_location)
			                             :rowNode.data.sel
			outData.push(rowNode.data)
	                    console.log('node ' + index + ' is in the grid');
	                    console.log(rowNode.data)
	    });
	    // set arrived to true for all selected rows
		selRow.forEach(item => {outData[item.local_row_number-1].arrived = true});
		//combine sel and new_location to form new column
		selRow.forEach(item => {outData[item.local_row_number-1].myselnewlocation = !isNaN(item.new_location)?(item.sel+item.new_location):item.sel });
	    // ag-grid will change edited value to text this will cause issue when sending data back into R
	    // so need to change them to int. this will be case by case depend on what the origianl data is
	    outData = changeDataType(outData)
	    console.log(outData)
		// https://shiny.rstudio.com/articles/communicating-with-js.html
		// https://book.javascript-for-r.com/shiny-complete.html  chapter 12.8
		// variableName:inputHandlerName. variableName is griddata2 and inputHandler is defined in /R/zzz.R call aggrid.griddata
		Shiny.setInputValue('griddata2:aggrid_griddata', outData);

		console.log(selRow)
		Shiny.setInputValue('griddata3:aggrid_griddata', selRow);

		Shiny.setInputValue('unsaved_changes', false);

		var unsaved_warning_button = document.getElementById("unsaved_warning_button");
		if (unsaved_warning_button) {
			unsaved_warning_button.style.visibility = "hidden";
		}
		//aggrid.events.on('setcellvalues', sendChangeEvent); // start listening for changes again
	}
}

var editedRow = []
// keep track of cell that has been updated. so we can keep track of which cell has been modified. but updating color still not
//working yet
var editedCell = []
// Define column definitions


// Create ag-Grid table
const gridContainer = document.querySelector("#grid-container");

// clear list after creation
// clear editedRow



// Define cell value changed event handler
function onCellValueChanged(event) {
  // Update the row data with the new value
  console.log("onCellValueChanged")
  //console.log(event)
  editedRow.push(event.rowIndex)
  //console.log("edited "+editedRow)
  event.data[event.colDef.field] = event.newValue;
  //console.log(event.colDef.field)
  // save the old value
  //editedCell[event.rowIndex][tableHeader.indexOf(event.colDef.field)] = event.oldValue
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
  if (event.colDef.field == 'num_piece') {
	if ( isNaN(Number(event.newValue)) ) {
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
  if (event.colDef.field == 'num_carton') {
  	if ( isNaN(Number(event.newValue)) ) {
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
  // how to validate date in javascript


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

