xquery version "3.0";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace vsm ="http://clarin.ids-mannheim.de/standards/view-spec" at "../modules/view-spec.xql";
import module namespace tm ="http://clarin.ids-mannheim.de/standards/topic-module" at "../modules/topic.xql";

let $id := request:get-parameter('id', '')
let $spec := vsm:get-spec($id)
let $spec-name := $spec/titleStmt/title/text()
let $spec-topic := vsm:get-spec-topic($spec)
return
<html>
    <head>
       <title>{$spec-name}</title>       
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("tagclouds.css","css")}"/>        
        <script type="text/javascript" src="{app:resource("d3.v2.js","js")}"/>
        <script type="text/javascript" src="{app:resource("forcegraph.js","js")}"/>
        <script type="text/javascript" src="{app:resource("tagcanvas.min.js","js")}"/>
        <script type="text/javascript" src="{app:resource("tagclouds.js","js")}"/>
        <script type="text/javascript" src="{app:resource("edit.js","js")}"/>
    </head>
       <!--body onload="createTags();drawGraph('{$json}','300','-400');setRespIds({$resp-ids})" -->
       <body onload="createTags();drawGraph('{vsm:get-spec-json($spec)}','500','300','-200')">       
            <div id="all">
                <div class="logoheader"/>		
                     {menu:view()}
                <div class="content">
                    <div class="navigation">
                        &gt; <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">Standards</a>
                        &gt; <a href="{app:link(concat("views/view-spec.xq?id=", $id))}">{$spec-name}</a>
                    </div>                          
                      {vsm:print-spec-name($spec,$spec-name)}
                      {vsm:print-spec-scope($spec)}
                      {vsm:print-spec-topic($spec,$spec-topic)}
                      {vsm:print-spec-sb(data($spec/@standardSettingBody), $id)}
                      {vsm:print-spec-keywords($spec/keyword, $id)}                     
                     <div id="myCanvasContainer" style="border: 1px solid #DDDDDD; border-radius:3px; align:center">
                            <canvas width="650" height="250" id="myCanvas"/>
                     </div>
                     <div id="tags" style="display:none" >
                        <a style="font-size:22px" onclick="return false">{app:name($spec)}</a>
                        <span style="font-size:18px">{tm:print-topic($spec,$spec-topic,"tag")}</span>
                        {vsm:print-keyword-links($spec)}
                        {vsm:print-sb-link($spec/@standardSettingBody)}
                        {vsm:print-version-links($spec,$spec/keyword)}
                     </div>
                     
                     <div>{vsm:print-spec-description($spec/info[@type="description"]/*, $id)}</div>
                     {vsm:print-spec-assets($id,$spec/asset/a)}
                     {vsm:print-topic-specs($id,$spec-topic)}
                     {vsm:print-spec-bibliography($spec/info[@type="recReading"]/biblStruct)}
                     <br/>
                     
                     <!--webadmin add part/version-->                        
                     {vsm:print-add-button($id)}
                     {vsm:print-spec-part($spec)}
                     {vsm:print-spec-version($spec)}   
                     
                     {if ($spec/descendant-or-self::version)
                      then vsm:print-graph($spec/descendant-or-self::version/relation/@type)                     
                      else ()}
                </div>
                <div class="footer">{app:footer()}</div>
           	</div>
       </body>       
</html>