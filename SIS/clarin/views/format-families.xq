xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module" at "../modules/format.xql";
import module namespace ff = "http://clarin.ids-mannheim.de/standards/format-family" at "../modules/format-family.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

let $sortBy := request:get-parameter('sortBy', '')
let $code := "

"
return

<html lang="en">
    <head>
        <title>Format Families</title>
        <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        <script>
            var graphJson = '{ff:create-graph-json()}';
            
            document.addEventListener('DOMContentLoaded', function() {{
                window.onload = init();
            }});
        
             function init(){{
                 checkActiveRI();
                 drawGraph(graphJson,'720','700','-100');
             }}
           
        </script>
        <script type="text/javascript" src="{app:resource("d3.v2.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("forcegraph.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
    </head>
    <body>
        <div id="all">
            <div class="logoheader"/>
            {menu:view()}
            <div class="content">
                <div class="navigation">&gt; <a href="{app:link("views/format-families.xq")}">Format Families</a></div>
                <div>
                <p>This page is made visible only to the most seasoned, relentless, and uncompromising discoverers 
                of the murky internals of the SIS. It shows yet another idea for how information on formats may be traversed. 
                It builds on the ideas sketched in the 
                <a href="https://github.com/clarin-eric/standards/blob/master/MM/Formal%20Format%20Families.png">formal 
                families tree graphic</a>, available from this repository. Feel welcome to add your suggestions to the 
                    <a href="https://github.com/clarin-eric/standards/issues/201">discussion at GitHub</a>.</p>
                    <p>Below the SISghetti Monster is a table listing the current relationships across the families.</p>
                
                </div>
                
                <div id="chart" class="version"></div>
                
                <div>
                <table>
                    <tr>
                        <th><a href="{app:link("views/format-families.xq?sortBy=id")}">Format</a></th>
                        <th><a href="{app:link("views/format-families.xq?sortBy=ff")}">Format Family</a></th>
                    </tr>
                    {fm:get-format-families($sortBy)}
                </table>
                </div>
                <!-- <div id="chart" class="version"></div> -->
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>