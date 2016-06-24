// pull in desired CSS/SASS files
require( './styles/main.scss' );

//Mdl
require( './mdl/material.min.css' );
require( './mdl/material.min.js' );
require( 'material-design-lite/material.css' );
require( 'material-design-lite/material.js' );

// inject bundled Elm app into div#main
var Elm = require( './Main' );
var app = Elm.Main.embed( document.getElementById( 'main' ) );

//Local storage
//Save the data
app.ports.save.subscribe(function(data){
	localStorage.setItem("data", JSON.stringify(data));
	console.log("Saving data...")
});

//Load the data
var savedData = localStorage.getItem("data");
window.setTimeout(function(){
	app.ports.load.send(JSON.parse(savedData));
	console.log("Loaded data")
	console.log(savedData)
});
