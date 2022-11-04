
# dataGridsInShiny

The goal of dataGridsInShiny is to show how to use a selection of Javascript grid package in a Shiny app.  The packages we use are:

- [datagrdXL](https://www.datagridxl.com),

Our imagined use case is a Shiny developer that wants to provide the user with the ability to create, view, edit and delete data contained in a database table.  At the time of writing the Shiny code, the developer is able to specify the key details about the table such as the names of the columns, the datatypes of the columns, which columns are editable, and so on.  Typically the JS grid expects to receive these in JSON format when the grid is created, although sometimes you can use a JS method to modify on the fly.  The Shiny developer should prepare these options in a nested list structure that will automagically be converted to JSON.

The JS grid will come with it's own methods and events.  The Shiny developer should use an adhoc JavaScript file to specify how they want to use these.  The main purpose of this repo is to provide JavaScript model code for a Shiny developer who may be inexperienced in JavaScript (like me).  A key concept is that the grid should handle things related to the grid.  Shiny should not be informed every time the user changes a cell.  Instead, add an HTML button with on `onClick` attribute the triggers JS code to update a Shiny input.  The grid should not participate in the reactive chain, except for when the user submits their changes, and when the table is initially created (at Shiny's request).


An excellent resource is the free online book [JavaScript for R](https://book.javascript-for-r.com) by John Coene.  I learned how to do the techniques employed in Chapters 11 and 12.

## Installation

You can install the development version of dataGridsInShiny from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("michael-dewar/dataGridsInShiny")
```

But it will be most useful for you to download a copy of the repo so that you can easily look at the code in the `inst` folder.

## How To Use This Package

Look at the example apps in the subfolders of `inst`.  Each grid type has its own example apps.
