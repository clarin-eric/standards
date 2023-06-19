xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module" at "../modules/format.xql";
import module namespace ff = "http://clarin.ids-mannheim.de/standards/format-family" at "../modules/format-family.xql";

let $sortBy := request:get-parameter('sortBy', '')
return

<html>
    <head>
        <title>Format Families</title>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        <script type="text/javascript" src="{app:resource("d3.v2.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("forcegraph.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("session.js", "js")}"/>"/>
    </head>
    <body onload="drawGraph('{ff:create-graph-json()}','720','700','-100');">
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
                
                <table>
                    <tr>
                        <th><a href="{app:link("views/format-families.xq?sortBy=id")}">Format</a></th>
                        <th><a href="{app:link("views/format-families.xq?sortBy=ff")}">Format Family</a></th>
                    </tr>
                    {fm:get-format-families($sortBy)}
                </table>
                </div>
                <div id="chart" class="version"></div>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>