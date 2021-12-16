xquery version "3.0";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module" at "../modules/centre.xql";

(: Define centre page 
   @author margaretha
   @date Dec 2021
:)


let $id := request:get-parameter('id', '')
let $domain := request:get-parameter('domain', '')
let $recommendationType := request:get-parameter('type', '')
let $sortBy := request:get-parameter('sortBy', '')

let $centre := cm:get-centre($id)
let $centre-name := $centre/name/text()
let $centre-link := data($centre/a/@href)
let $centre-info := $centre/info
let $centre-ri := $centre/nodeInfo/ri

return
    
    <html>
        <head>
            <title>Centre: {$id}</title>
            <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
            <script type="text/javascript" src="{app:resource("d3.v2.js", "js")}"/>
            <script type="text/javascript" src="{app:resource("forcegraph.js", "js")}"/>
        </head>
        
        <!--<body onload="drawGraph('{sbm:get-sb-json($id)}','500','300','-100');">-->
        <body>
            <div id="all">
                <div class="logoheader"/>
                {menu:view()}
                {
                    if ($centre) then
                        <div class="content">
                            <div class="navigation">
                                &gt; <a href="{app:link("views/list-centres.xq")}">Centres</a>
                                &gt; <a href="{app:link(concat("views/view-centre.xq?id=", $id))}">{$centre-name}</a>
                            </div>
                            <div class="title">{$centre-name}</div>
                            <div>
                                <span class="heading">Abbreviation: </span>
                                <span id="abbrtext" class="heading">{$id}</span>
                            </div>
                            <div>
                                <span class="heading">Link: </span>
                                <span id="link"><a href="{$centre-link}">{$centre-link}</a></span>
                            </div>
                            <div>
                                <span class="heading">Research Infrastructure: </span>
                                <span id="ri">{$centre-ri/text()}</span>
                            </div>
                            <div>
                                <span class="heading">Status(es): </span>
                                <span id="ri">{data($centre-ri/@status) }</span>
                            </div>
                            {
                                if ($centre-info)
                                then
                                    <div>
                                        <span class="heading">Description: </span>
                                        <span id="desctext{$id}" class="desctext">{$centre-info}</span>
                                    </div>
                                else
                                    ()
                            }
                            {cm:print-recommendation-table($id,$sortBy)}
                        </div>
                    else
                        <div class="content">
                            <div class="navigation">
                                &gt; <a href="{app:link("views/list-centres.xq")}">Centres</a>
                            </div>
                            <div><span class="heading">The requested centre information is not found.</span></div>
                        </div>
                }
                <div class="footer">{app:footer()}</div>
            </div>
        </body>
    </html>