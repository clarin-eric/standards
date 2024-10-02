xquery version "3.1";

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
let $registry-links := $centre/registryLink
let $isDepositing := cm:isDepositing($centre)
let $centre-ri := $centre/nodeInfo/ri

let $recommendation := cm:get-recommendations($id)

let $languageHeader := fn:substring(request:get-header("Accept-Language"),0,3)
let $ri :=  request:get-cookie-value("ri")
let $languageHeader := if (not($ri eq "CLARIN") and not($ri eq "all")) then "de" else $languageHeader
let $centre-info := cm:get-centre-info($id,$languageHeader)

let $exportFilename := concat($id,"-recommendation.xml")
let $domains := fn:distinct-values($recommendation/formats/format/domain/text())

return
if ($export)
then (em:export-table("", $id, (), "", 
            rf:print-centre-recommendation($id,(), "", $sortBy,$languageHeader,$ri),
            $exportFilename, "views/view-centre.xq", $centre-info))
else if ($template)
then (em:download-template($id,$exportFilename))
else 
    
    <html lang="en">
        <head>
            <title>Centre: {$id}</title>
            <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
            <script type="text/javascript" src="{app:resource("d3.v2.js", "js")}"/>
            <script type="text/javascript" src="{app:resource("forcegraph.js", "js")}"/>
            <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
            <script type="text/javascript" src="{app:resource("utils.js", "js")}"/>
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
                            {
                            if (not(rf:isCurated($recommendation)))
                            then
                            <div style="float:right;">
                                <span>
                                    <a href="{cm:getGithubCentreIssueLink($id)}" class="button" 
                                        style="margin-left:5px; padding: 5px 5px 2px 5px; height:25px;
                                        color:darkred; border-color:darkred">
                                        Suggest a fix or extension</a>
                                </span>
                            </div>
                            else ()
                            }
                            <div>
                                <span class="heading">Abbreviation: </span>
                                <span id="abbrtext" class="heading">{$id}</span>
                            </div>
                            {
                            if (count($registry-links) eq 1)
                            then 
                            <div>
                                <span class="heading">Link: </span>
                                {
                                    let $uri := data($registry-links/@uri)
                                    let $label := 
                                           if (data($registry-links/@label))
                                           then
                                             concat('   (',data($registry-links/@label), ')')
                                           else () 
                                     
                                     return
                                    <span id="reg-link"><a href="{$uri}">{$uri}</a>{$label}</span>
                                 }

                             </div>                            
                             else 
                             <div>
                                <span class="heading">Links: </span>
                                <ul>
                                {
                                    for $registry-link at $pos in ($registry-links)
                                       let $uri := data($registry-link/@uri)
                                       let $label := 
                                           if (data($registry-link/@label))
                                           then
                                             concat('   (',data($registry-link/@label), ')')
                                           else () 
                                    return 
                                      <li><span id="{concat('reg-link_',$pos)}"><a href="{$uri}">{$uri}</a></span><span id="{concat('reg-label_',$pos)}">{$label}</span></li>
                                 }
                                 </ul>

                             </div>
                            
                           }

                            <div>
                                <span class="heading">Research infrastructure: </span>
                                <ul>{cm:print-ri($centre-ri)}</ul>
                            </div>
                            {
                                if ($isDepositing)
                                then 
                                    rf:print-curation($recommendation,$languageHeader)
                                else ()
                            }
                            {
                                if ($centre-info/*)
                                then
                                    <div>
                                        <span class="heading">Description: </span>
                                        {$centre-info}
                                    </div>
                                else
                                    ()
                            }
                            
                            {
                                if (count($domains)>0)
                                then(
                                    <div> {app:create-collapse-expand("domainList", 
                                        <span class="heading">Data functions covered by the recommendations: </span>, 
                                        for $d in $domains return <li>{$d}</li>, "")
                                    }
                                        <!--
                                        <span class="heading">Data functions covered by the recommendations</span>
                                        <div>
                                        <span class="desctext">Recommendations provided by this centre concern the following <a href="{app:link('views/list-domains.xq')}">functions of data</a>:</span>
                                            <ul>
                                                {
                                                    for $d in $domains
                                                    return <li>{$d}</li>
                                                }
                                            </ul>
                                        </div>
                                        -->
                                    </div>
                                )
                                else ()
                            }
                            
                            {
                                if (count($recommendation/formats/format)>0)
                                then (
                                    <div>
                                        <span class="heading" id="recommendationTable">Format recommendations: </span>
                                       
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
                                     {cm:print-recommendation-rows($recommendation, $id, $sortBy, $languageHeader)}
                                    </table>
                                    ,
                                    <div style="text-align:right;">
                                        <span >Last update commit-id: </span>
                                        <span id="commit-id">{cm:getLastUpdateCommitId($id)}</span>
                                    </div>
                                    )
                                else (
                                        if ($isDepositing)
                                        then (
                                        
                                    <div>
                                        <span class="heading" id="recommendationTable">Recommendations: </span>
                                        <span>not yet available in the SIS</span>
                                        <form method="get" action="" style="float: right;">
                                              <input name="template" class="button"
                                              style="margin-bottom:5px; height:25px;width:165px;" 
                                              type="submit" value="Download template"/>
                                              <input name="id" type="hidden" value="{$id}"/>
                                       </form>
                                    </div>
                                            )
                                        else ()
                                )
                            }
                            {
                            if (rf:isCurated($recommendation))
                            then
                            <div style="float:right;">
                                <span>
                                    <a href="{cm:getGithubCentreIssueLink($id)}" class="button" 
                                        style="margin-left:5px; padding: 5px 5px 2px 5px; height:25px;
                                        color:darkred; border-color:darkred">
                                        Suggest a fix or extension</a>
                                </span>
                            </div>
                            else ()
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