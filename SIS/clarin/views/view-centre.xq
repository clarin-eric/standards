xquery version "3.0";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module" at "../modules/centre.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";
import module namespace em = "http://clarin.ids-mannheim.de/standards/export" at "../modules/export.xql";

(: Describes a centre and  lists formats recommended by that centre

   @author margaretha
:)


let $id := request:get-parameter('id', '')
let $recommendationType := request:get-parameter('type', '')
let $sortBy := request:get-parameter('sortBy', '')
let $export := request:get-parameter('export', '')
let $template := request:get-parameter('template', '')

let $centre := cm:get-centre($id)
let $centre-name := $centre/name/text()
let $centre-link := data($centre/a/@href)

let $centre-ri := $centre/nodeInfo/ri

let $recommendation := cm:get-recommendations($id)
let $languageHeader := fn:substring(request:get-header("Accept-Language"),0,3)
let $centre-info := $recommendation/info[@xml:lang =$languageHeader] 
let $recommendationRows := rf:print-centre-recommendation($id,(), "", $sortBy)
let $exportFilename := concat($id,"-recommendation.xml")
let $respStmt := $recommendation/header/respStmt

return
if ($export)
then (em:export-table($id, (), "", $recommendationRows,$exportFilename, "views/view-centre.xq", $centre-info))
else if ($template)
then (em:download-template($id,$exportFilename))
else 
    
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
                            <div style="float:right;">
                                <span>
                                    <a href="{cm:getGithubCentreIssueLink($id)}" class="button" 
                                        style="margin-left:5px; padding: 5px 5px 2px 5px; height:25px;
                                        color:darkred; border-color:darkred">
                                        Suggest a fix or extension</a>
                                </span>
                            </div>
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
                                <span id="ri">{$centre-ri/text()} ({data($centre-ri/@status)})</span>
                            </div>
                            {cm:print-curation($respStmt,$languageHeader)}
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
                            
                            {
                                if (count($recommendation/formats/format)>0)
                                then (
                                    <div>
                                        <span class="heading" id="recommendationTable">Recommendations: </span>
                                       
                                        <form method="get" action="" style="float: right;">
                                              <input name="export" class="button"
                                              style="margin-bottom:5px; height:25px;width:165px;" 
                                              type="submit" value="Export table to XML"/>
                                              <input name="id" type="hidden" value="{$id}"/>
                                              <input name="sortBy" type="hidden" value="{$sortBy}"/>
                                       </form>
                                    </div>
                                     ,
                                    <table cellspacing="4px" style="width:97%">
                                     <tr>
                                         <th class="header" style="width:15%;">
                                             <a href="{
                                                         app:link(concat("views/view-centre.xq?id=", $id, "&amp;sortBy=format#recommendationTable"))
                                                     }">Format</a>
                                         </th>
                                         <th class="header" style="width:30%;">
                                             <a href="{
                                                         app:link(concat("views/view-centre.xq?id=", $id, "&amp;sortBy=domain#recommendationTable"))
                                                     }">Domain</a></th>
                                         <th class="header" style="width:15%;">
                                             <a href="{
                                                         app:link(concat("views/view-centre.xq?id=", $id, "&amp;sortBy=recommendation#recommendationTable"))
                                                     }">
                                                 Level</a></th>
                                         <th class="header" style="width:40%;">
                                             Comments
                                         </th>
                                     </tr>
                                     {cm:print-recommendation-rows($recommendation, $id, $sortBy)}
                                    </table>
                                    ,
                                    <div style="text-align:right;">
                                        <span >Last update commit-id: </span>
                                        <span id="commit-id">{cm:getLastUpdateCommitId($id)}</span>
                                    </div>
                                    )
                                else (
                                    <div>
                                        <span class="heading" id="recommendationTable">Recommendations: </span>
                                        <span>not available</span>
                                        <form method="get" action="" style="float: right;">
                                              <input name="template" class="button"
                                              style="margin-bottom:5px; height:25px;width:165px;" 
                                              type="submit" value="Download template"/>
                                              <input name="id" type="hidden" value="{$id}"/>
                                       </form>
                                    </div>
                                )
                            }
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