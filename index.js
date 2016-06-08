// pull in desired CSS/SASS files
require( './styles/main.scss' );

//Mdl
require( './mdl/material.min.css' );
require( './mdl/material.min.js' );
require( 'material-design-lite/material.css' );
require( 'material-design-lite/material.js' );

// inject bundled Elm app into div#main
var Elm = require( './Main' );
Elm.Main.embed( document.getElementById( 'main' ) );
