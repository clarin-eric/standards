xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace vfm = "http://clarin.ids-mannheim.de/standards/view-format" at "../modules/view-format.xql";
import module namespace vsm = "http://clarin.ids-mannheim.de/standards/view-spec" at "../modules/view-spec.xql";

let $id := request:get-parameter('id', '')
let $centre := request:get-parameter('centre', '')
let $domain := request:get-parameter('domain', '')
let $recommendationType := request:get-parameter('type', '')
let $sortBy := request:get-parameter('sortBy', '')

let $format := vfm:get-format($id)
let $format-name := $format/titleStmt/title/text()
let $format-abbr := $format/titleStmt/abbr/text()

return
    
    if (not($id) or not($format)) then
        <html>
            <head>
                <title>Not Found</title>
                <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
            </head>
            <body>
                <div id="all">
                    <div class="logoheader"/>
                    {menu:view()}
                    <div class="content">
                        <div class="navigation"> &gt;
                            <a href="{app:link("views/recommended-formats-with-search.xq")}">Data Deposition Formats</a>
                        </div>
                        <div><span class="heading">The requested format information is not found.</span></div>
                    </div>
                    <div class="footer">{app:footer()}</div>
                </div>
            </body>
        </html>
    else
        <html>
            <head>
                <title>{$format-name}</title>
                <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
                <link rel="stylesheet" type="text/css" href="{app:resource("tagclouds.css", "css")}"/>
                <link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/dojo/1.9.1/dijit/themes/claro/claro.css" media="screen"/>
                <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/dojo/1.9.1/dojo/dojo.js"
                    data-dojo-config="async: true, parseOnLoad: true"/>
                <script>require(["dojo/parser", "dijit/form/ComboBox"]);</script>
                <script type="text/javascript" src="{app:resource("d3.v2.js", "js")}"/>
                <script type="text/javascript" src="{app:resource("forcegraph.js", "js")}"/>
                <script type="text/javascript" src="{app:resource("tagcanvas.min.js", "js")}"/>
                <script type="text/javascript" src="{app:resource("tagclouds.js", "js")}"/>
                <script type="text/javascript" src="{app:resource("tinymce/tinymce.min.js", "js")}"/>
                <script type="text/javascript" src="{app:resource("xmleditor.js", "js")}"/>
            </head>
            <body onload="createTags();drawGraph('{vsm:get-spec-json($format)}','500','300','-200')">
                <div id="all">
                    <div class="logoheader"/>
                    {menu:view()}
                    <div class="content">
                        <div class="navigation"> &gt;
                            <a href="{app:link("views/recommended-formats-with-search.xq")}">Data Deposition Formats</a> &gt;
                            <a href="{app:link(concat("views/view-format.xq?id=", $id))}">{$format-name}</a>
                        </div>
                        
                        <div class="title">
                            <span id="nametext">{$format-name}</span>
                        </div>
                        
                        <div>
                            <span class="heading">Abbreviation: </span>
                            <span id="abbrtext" class="heading">
                                {$format-abbr}</span>
                        </div>
                        
                        {vfm:print-multiple-values($format/titleStmt/versionNumber, $id, "Versions:")}
                        
                        {vfm:print-multiple-values($format/mimeType, $id, "MIME types:")}
                        {vfm:print-multiple-values($format/fileExt, $id, "File extensions:")}
                        {vfm:print-multiple-values($format/formatFamily, $id, "Format family:")}
                        {vfm:print-multiple-values($format/schemaLoc, $id, "Schema locations:", fn:true())}
                        
                        
                        {vfm:print-recommendation-in-clarin($format,$id)}
                        {vfm:print-recommendation-table($id,$domain,$centre,$recommendationType,$sortBy)}
                        
                        {vfm:print-multiple-values($format/keyword, $id, "Keywords:")}
                        <!--The tag cloud of the standard related keywords -->
                        <div id="myCanvasContainer" style="border: 1px solid #DDDDDD; border-radius:3px; align:centre">
                            <canvas width="650" height="250" id="myCanvas"/>
                        </div>
                        <div id="tags" style="display:none">
                            <a style="font-size:22px" onclick="return false">{$format-abbr}</a>
                            {vsm:print-keyword-links($format)}
                        </div>
                        
                        
                        
                        <div>
                            <span class="heading">Description: </span>
                            <span id="desctext{$id}" class="desctext">{$format/info[@type = "description"]}</span>
                        </div>
                        
                        {vsm:print-spec-relation($format,$id, fn:true())}
                        {vsm:print-graph($format)}
                    </div>
                    <div class="footer">{app:footer()}</div>
                </div>
            </body>
        </html>