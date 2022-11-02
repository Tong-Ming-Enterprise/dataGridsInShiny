var datagridxlOutput = new Shiny.OutputBinding();

$.extend(datagridxlOutput, {
  // find outputs
  find: function(scope) {
    return $(scope).find(".datagridxlr");
  },

  renderValue: function(el, data){
  	//var some_data = [
  	//	[1, 2, 3],
	//	["a", "b", "c"],
	//	["d", "e", "f"]
	//];
	//var grid = new DataGridXL(el.id, {data: some_data});
	console.log(data);

	var grid = new DataGridXL(el.id, data);
  }

});

Shiny.outputBindings.register(datagridxlOutput, "datagridxlr");
