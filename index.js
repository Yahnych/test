//pull in desired CSS,SASS file

//Mdl
require( './mdl/material.min.css' );
require( './mdl/material.min.js' );
//require( 'material-design-lite/material.css' );
//require( 'material-design-lite/material.js' );

//Marked
//var marked = require("marked");
var marked = require("./scripts/marked.min.js");

//jsPDF
//require("jspdf");
require("./scripts/jsPDF.js")

//pdfMake
require("./scripts/pdfMake.js")
require("./scripts/vfs_fonts.js")

//jQuery
require("./scripts/jquery-3.0.0.min.js")

//Object.assign polyfill
if (typeof Object.assign != 'function') {
  Object.assign = function(target) {
    'use strict';
    if (target == null) {
      throw new TypeError('Cannot convert undefined or null to object');
    }

    target = Object(target);
    for (var index = 1; index < arguments.length; index++) {
      var source = arguments[index];
      if (source != null) {
        for (var key in source) {
          if (Object.prototype.hasOwnProperty.call(source, key)) {
            target[key] = source[key];
          }
        }
      }
    }
    return target;
  };
}



//inject bundled Elm app into div #main
var Elm = require( './Main' );
var app = Elm.Main.embed( document.getElementById( 'main' ) );

//Check for IE

function detectIE() {
  var ua = window.navigator.userAgent;

  // Test values; Uncomment to check result …

  // IE 10
  // ua = 'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)';
  
  // IE 11
  // ua = 'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko';
  
  // Edge 12 (Spartan)
  // ua = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36 Edge/12.0';
  
  // Edge 13
  // ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Safari/537.36 Edge/13.10586';

  var msie = ua.indexOf('MSIE ');
  if (msie > 0) {
    // IE 10 or older => return version number
    return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
  }

  var trident = ua.indexOf('Trident/');
  if (trident > 0) {
    // IE 11 => return version number
    var rv = ua.indexOf('rv:');
    return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
  }

  var edge = ua.indexOf('Edge/');
  if (edge > 0) {
    // Edge (IE 12+) => return version number
    return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
  }

  // other browser
  return 0;
}


app.ports.checkIeVersion.subscribe(function(initial){
  //var version = msieversion();
  var version = detectIE();
  console.log(version);
  setTimeout(function(){app.ports.ieVersion.send(version);},0);
});

//Hide the Word and PDF buttons on older versions of IE
/*
if (msieversion() > 0 && msieversion() < 12){
  console.log(msieversion());
  document.getElementById("buttonContainer").style.display = "none";
}
*/


//Local storage

//localStorage.clear();

//Save the data
var dataFile = "chv2oq_7.2.6";

app.ports.save.subscribe(function(data){
  localStorage.setItem(dataFile, JSON.stringify(data));
  //console.log("*** Saving data...")
  //console.log(JSON.stringify(data))
});

//Load the data
var savedData = localStorage.getItem(dataFile);
window.setTimeout(function(){
  app.ports.load.send(JSON.parse(savedData));
  //console.log("*** Loaded data")
  //console.log(savedData)
}, 0);

//Download file
app.ports.download.subscribe(function(elmData) {
	var filename = elmData[0];
	var data = elmData[1];
	var htmlData = toWord(marked(data));
	//console.log(htmlData)
	download(filename, htmlData);
  
});


function download(filename, data){
  var blob = new Blob([data], {type: 'text/csv'});
  if(window.navigator.msSaveOrOpenBlob) {
      window.navigator.msSaveBlob(blob, filename);
  }
  else{
      var elem = window.document.createElement('a');
      elem.href = window.URL.createObjectURL(blob);
      elem.download = filename;        
      document.body.appendChild(elem)
      elem.click();        
      document.body.removeChild(elem);
  }
}

function toWord(data){
  var xml 
    = "<xml><word:WordDocument>"
    + "<word:View>Print</word:View>"
    + "<word:Zoom>90</word:Zoom>"
    + "<word:DoNotOptimizeForBrowser/>"
    + "</word:WordDocument>"
    + "</xml>";

  var meta = "<meta charSet='utf-8'/>";

	return "<html lang='en-us'><head>" + meta + xml + "</head><body>" + data + "</body></html>"
}


app.ports.pdf.subscribe(function(elmData) {
	var filename = elmData[0];
	var data = elmData[1];
	var htmlData = formatHtml(marked(data));
  //pdfForElement("essay").download();

  //Turn the html formatted markdown document into a pdf 
  //using `pdfmake` and http://jsfiddle.net/mychn9bo/75/
  pdfForElement(marked(data)).open(filename);
	/*
	console.log(htmlData);
	var doc = new jsPDF();
	doc.encoding = "WinAnsiEncoding"
	
	var specialElementHandlers = {
	  '#editor': function(element, renderer){
		 return true;
	  }
  };
  
  //doc.fromHTML(htmlData, 30, 30);
   
  doc.fromHTML(htmlData, 30, 30, { 
  	'width': 150,
  	'elementHandlers': specialElementHandlers,
  	'encoding': "WinAnsiEncoding"
   });
  
  doc.save(filename);
  */
});

function formatHtml(data){
	var meta = "<meta charSet='utf-8'/>";
	return "<html lang='en-us'><head>" + meta + "</head><body>" + data + "</body></html>"
}


//Html to PDF parser
//function pdfForElement(id) {
function pdfForElement(html) {
  function ParseContainer(cnt, e, p, styles) {
    var elements = [];
    var children = e.childNodes;
    if (children.length != 0) {
      for (var i = 0; i < children.length; i++) p = ParseElement(elements, children[i], p, styles);
    }
    if (elements.length != 0) {
      for (var i = 0; i < elements.length; i++) cnt.push(elements[i]);
    }
    return p;
  }

  function ComputeStyle(o, styles) {
    for (var i = 0; i < styles.length; i++) {
      var st = styles[i].trim().toLowerCase().split(":");
      if (st.length == 2) {
        switch (st[0]) {
          case "font-size":
            {
              o.fontSize = parseInt(st[1]);
              break;
            }
          case "text-align":
            {
              switch (st[1]) {
                case "right":
                  o.alignment = 'right';
                  break;
                case "center":
                  o.alignment = 'center';
                  break;
              }
              break;
            }
          case "font-weight":
            {
              switch (st[1]) {
                case "bold":
                  o.bold = true;
                  break;
              }
              break;
            }
          case "text-decoration":
            {
              switch (st[1]) {
                case "underline":
                  o.decoration = "underline";
                  break;
              }
              break;
            }
          case "font-style":
            {
              switch (st[1]) {
                case "italic":
                  o.italics = true;
                  break;
              }
              break;
            }
        }
      }
    }
  }

  function ParseElement(cnt, e, p, styles) {
    if (!styles) styles = [];
    if (e.getAttribute) {
      var nodeStyle = e.getAttribute("style");
      if (nodeStyle) {
        var ns = nodeStyle.split(";");
        for (var k = 0; k < ns.length; k++) styles.push(ns[k]);
      }
    }

    switch (e.nodeName.toLowerCase()) {
      case "#text":
        {
          var t = {
            text: e.textContent.replace(/\n/g, "")
          };
          if (styles) ComputeStyle(t, styles);
          p.text.push(t);
          break;
        }
      case "b":
      case "strong":
        {
          //styles.push("font-weight:bold");
          ParseContainer(cnt, e, p, styles.concat(["font-weight:bold"]));
          break;
        }
      case "u":
        {
          //styles.push("text-decoration:underline");
          ParseContainer(cnt, e, p, styles.concat(["text-decoration:underline"]));
          break;
        }
      case "i":
      case "em":
        {
          //styles.push("font-style:italic");
          ParseContainer(cnt, e, p, styles.concat(["font-style:italic"]));
          //styles.pop();
          break;
          //cnt.push({ text: e.innerText, bold: false });
        }
      case "span":
        {
          ParseContainer(cnt, e, p, styles);
          break;
        }
      case "br":
        {
          p = CreateParagraph();
          cnt.push(p);
          break;
        }
      case "h1":
        {
          //ParseContainer(cnt, e, p, styles.concat(["font-size:3em"]));
          p = CreateParagraph();
          cnt.push({ text: e.innerText + "\n\n", bold: true, fontSize: 18, alignment: "center" });
          break;
        }
      /*
      case "p":
        {
          p = CreateParagraph();
          cnt.push({ text: e.innerText + "\n" });
          break;
        }
       */
      case "table":
        {
          var t = {
            table: {
              widths: [],
              body: []
            }
          }
          var border = e.getAttribute("border");
          var isBorder = false;
          if (border)
            if (parseInt(border) == 1) isBorder = true;
          if (!isBorder) t.layout = 'noBorders';
          ParseContainer(t.table.body, e, p, styles);

          var widths = e.getAttribute("widths");
          if (!widths) {
            if (t.table.body.length != 0) {
              if (t.table.body[0].length != 0)
                for (var k = 0; k < t.table.body[0].length; k++) t.table.widths.push("*");
            }
          } else {
            var w = widths.split(",");
            for (var k = 0; k < w.length; k++) t.table.widths.push(w[k]);
          }
          cnt.push(t);
          break;
        }
      case "tbody":
        {
          ParseContainer(cnt, e, p, styles);
          //p = CreateParagraph();
          break;
        }
      case "tr":
        {
          var row = [];
          ParseContainer(row, e, p, styles);
          cnt.push(row);
          break;
        }
      case "td":
        {
          p = CreateParagraph();
          var st = {
            stack: []
          }
          st.stack.push(p);

          var rspan = e.getAttribute("rowspan");
          if (rspan) st.rowSpan = parseInt(rspan);
          var cspan = e.getAttribute("colspan");
          if (cspan) st.colSpan = parseInt(cspan);

          ParseContainer(st.stack, e, p, styles);
          cnt.push(st);
          break;
        }
      case "div":
      case "p":
        {
          p = CreateParagraph();
          var st = {
            stack: [],
            //margin: [50,5],
            lineHeight: 2
          }
          st.stack.push(p);
          ComputeStyle(st, styles);
          ParseContainer(st.stack, e, p);

          cnt.push(st);
          break;
        }
      default:
        {
          console.log("Parsing for node " + e.nodeName + " not found");
          break;
        }
    }
    return p;
  }

  function ParseHtml(cnt, htmlText) {
    var html = $(htmlText.replace(/\t/g, "").replace(/\n/g, ""));
    var p = CreateParagraph();
    for (var i = 0; i < html.length; i++) ParseElement(cnt, html.get(i), p);
  }

  function CreateParagraph() {
    var p = {
      text: []
    };
    return p;
  }
  content = [];
  //ParseHtml(content, document.getElementById(id).outerHTML);
  ParseHtml(content, html);
  return pdfMake.createPdf({
    content: content,
    pageMargins: [100, 50]
  });
}