xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace vsm ="http://clarin.ids-mannheim.de/standards/view-spec" at "../modules/view-spec.xql";
import module namespace tm ="http://clarin.ids-mannheim.de/standards/topic-module" at "../modules/topic.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(:  Define the standard page
    @author margaretha
    @date Dec 2013
:)

let $id := request:get-parameter('id', '')
let $spec := vsm:get-spec($id)
let $spec-name := $spec/titleStmt/title/text()
let $spec-abbr := $spec/titleStmt/abbr/text()
let $spec-topic := vsm:get-spec-topic($spec)

return

if (not($id) or not($spec))
then 

<html lang="en">
    <head>
        <title>Not Found</title>
        <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
        <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
    </head>    
    <body>
        <div id="all">
           <div class="logoheader"/>		
                {menu:view()}
           <div class="content">
               <div class="navigation">
                       &gt; <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">Standards</a>                    
                   </div>  
               <div><span class="heading">The requested standard information is not found.</span></div>
           </div>
           <div class="footer">{app:footer()}</div>
           </div>
       </body>
</html>


else
<html lang="en">
    <head>
       <title>{$spec-name}</title>
        <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("tagclouds.css","css")}"/>
        <link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/dojo/1.9.1/dijit/themes/claro/claro.css" media="screen"/>
        <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/dojo/1.9.1/dojo/dojo.js"
        data-dojo-config="async: true, parseOnLoad: true"/>    
        <script>require(["dojo/parser", "dijit/form/ComboBox"]);</script>
        <script type="text/javascript" src="{app:resource("d3.v2.js","js")}"/>
        <script type="text/javascript" src="{app:resource("forcegraph.js","js")}"/>
        <script type="text/javascript" src="{app:resource("tagcanvas.min.js","js")}"/>
        <script type="text/javascript" src="{app:resource("tagclouds.js","js")}"/>
        <script type="text/javascript" src="{app:resource("edit.js","js")}"/>
        <script type="text/javascript" src="{app:resource("tinymce/tinymce.min.js","js")}"/>
        <script type="text/javascript" src="{app:resource("xmleditor.js","js")}"/>
    </head>       
       <body onload="createTags();drawGraph('{vsm:get-spec-json($spec)}','500','300','-200')">
            <div id="all">
                <div class="logoheader"/>		
                     {menu:view()}
                <div class="content">
                    <div class="navigation">
                        &gt; <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">Standards and Specification</a>
                        &gt; <a href="{app:link(concat("views/view-spec.xq?id=", $id))}">{$spec-name}</a>
                    </div>                
                       
                      {vsm:print-spec-name($spec)}
                      {vsm:print-spec-abbr($spec)}
                      {vsm:print-spec-scope($spec)}                      
                      {vsm:print-spec-topic($spec,$spec-topic)}
                      {vsm:print-spec-sb(data($spec/@standardSettingBody), $id)}                      
                      {vsm:print-spec-keywords($spec/keyword, $id)}
                      {vsm:print-recommendation($spec,$id)}
                      
                      <!--The tag cloud of the standard related keywords -->
                     <div id="myCanvasContainer" style="border: 1px solid #DDDDDD; border-radius:3px; align:center">
                            <canvas width="650" height="250" id="myCanvas"/>
                     </div>
                     <div id="tags" style="display:none" >
                        <a style="font-size:22px" onclick="return false">{$spec-abbr}</a>
                        <span style="font-size:18px">{tm:print-topic($spec,$spec-topic,"tag")}</span>
                        {vsm:print-keyword-links($spec)}
                        {vsm:print-sb-link($spec/@standardSettingBody)}
                        {vsm:print-version-links($spec,$spec/keyword)}
                     </div>
                     
                     <div>{vsm:print-spec-description($spec/info[@type="description"], $id)}</div>                     
                     {vsm:print-url($spec)}
                     {vsm:print-spec-assets($id,$spec/asset/a)}
                     {vsm:print-spec-relation($spec,$id,fn:false())}
                     {vsm:print-topic-specs($id,$spec-topic)}
                     {vsm:print-spec-bibliography($spec/info[@type="recReading"]/biblStruct)}
                     <br/>
                     
                     <!-- Webadmin add part/version -->
                     {vsm:print-add-button($id)}
                     
                     <!-- Standard parts and versions -->                                          
                     {vsm:print-spec-version($spec)}
                     {vsm:print-spec-part($spec)}
                     
                     <!-- Standard relation diagram -->
                     {vsm:print-graph($spec)}
                </div>
                <div class="footer">{app:footer()}</div>
           	</div>
       </body>       
</html>