xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace rm = "http://clarin.ids-mannheim.de/standards/recommendation" at "../modules/recommendation.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";

let $reset := request:get-parameter('resetButton', '')
let $centre := if ($reset) then () else request:get-parameter('centre', '')
let $domainId := if ($reset) then () else request:get-parameter('domain', '')
let $recommendationType := if ($reset) then () else request:get-parameter('type', '')
let $sortBy := if ($reset) then () else request:get-parameter('sortBy', '')
let $export := request:get-parameter('exportButton', '')
let $recommendationTable := rf:print-recommendation($centre,$domainId, $recommendationType, $sortBy)

return
if ($export)
then (rf:export-table($centre, $domainId, $recommendationType, $recommendationTable,"format-recommendation.xml"))
else 

    <html>
        <head>
            <title>CLARIN Format Recommendations</title>
            <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        </head>
        <body>
            <div id="all">
                <div class="logoheader"/>
                {menu:view()}
                <div class="content">
                    <div class="navigation">
                        &gt; <a href="{app:link("views/recommended-formats-with-search.xq")}">Data Deposition Formats</a>
                    </div>
                    <div class="title" id="pagetitle">CLARIN Format Recommendations</div>
                    
                    <div><p>This page presents formats of data depositions that various CLARIN centres are ready to accept. Each format,
                            for each centre, can be recommended, acceptable or deprecated in the context of several domains that represent the
                            functions that the deposited data can play.</p> <!-- TODO: a link to a separate piece of documentation on the domains, when that page exists -->
                        <p>Use the dropboxes to select the particular domain, centre, and/or level of recommendation. Columns can be sorted, 
                           and your results can be downloaded as XML.</p></div>
                    <div style="margin-top:30px;">
                        <form id="searchRecommendation" style="float:left;" method="post" action="{app:link("views/recommended-formats-with-search.xq?#pagetitle")}">
                            <table style="margin:0;">
                                <tr>
                                    <td>
                                        <select name="centre" class="inputSelect" style="width:175px;">
                                            {rf:print-option($centre, "", "Select centre ...")}
                                            {rf:print-centres($centre)}
                                        </select>
                                    </td>
                                    <td>
                                        <select name="domain" class="inputSelect" style="width:175px;">
                                            {rf:print-option($domainId, "", "Select domain ...")}
                                            {rf:print-domains($domainId)}
                                        </select>
                                    </td>
                                    <td>
                                        <select name="type" class="inputSelect" style="width:175px;">
                                            {rf:print-option($recommendationType, "", "Select recommendation ...")}
                                            {rf:print-option($recommendationType, "r", "recommended")}
                                            {rf:print-option($recommendationType, "a", "acceptable")}
                                            {rf:print-option($recommendationType, "d", "deprecated")}
                                        </select>
                                    </td>
                                    <td>
                                        <input name="searchButton" class="button"
                                        style="margin:0;height:25px;" type="submit" value="Search"/>
                                    </td>
                                    <td>
                                        <input name="resetButton" class="button"
                                        style="margin-bottom:5px;height:25px;" type="submit" value="Reset"/>
                                    </td>
                                </tr>
                            </table>
                        </form>
                    </div>
                    <div>
                        <form method="get" action="" style="text-align:right;">
                            <input name="exportButton" class="button"
                            style="margin-bottom:5px; margin-right:2px; margin-top:20px; height:25px;width:165px;" type="submit" value="Export Table to XML"/>
                            <input name="centre" type="hidden" value="{$centre}"/>
                            <input name="domain" type="hidden" value="{$domainId}"/>
                            <input name="type" type="hidden" value="{$recommendationType}"/>
                            <input name="sortBy" type="hidden" value="{$sortBy}"/>
                        </form>
                    </div>
                    
                    <table id="recommendationTable" cellspacing="4px" style="width:97%">
                        <tr>
                            <th class="header" style="width:20%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=abbr&amp;domain=",
                                            $domainId, "&amp;type=", $recommendationType, "&amp;centre=",$centre, "#searchRecommendation"))
                                        }">Abbreviation</a>
                            </th>
                            <th class="header" style="width:20%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=centre&amp;domain=",
                                            $domainId, "&amp;type=", $recommendationType, "#searchRecommendation"))
                                        }">Clarin Centres</a>
                            </th>
                            <th class="header" style="width:40%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=domain&amp;domain=",
                                            $domainId, "&amp;type=", $recommendationType, "&amp;centre=",$centre,"#searchRecommendation"))
                                        }">Domain</a></th>
                            <th class="header" style="width:20%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=recommendation&amp;domain=",
                                            $domainId, "&amp;type=", $recommendationType, "&amp;centre=",$centre,"#searchRecommendation"))
                                        }">
                                    Recommendation</a></th>
                        </tr>
                        {$recommendationTable}
                    </table>
                </div>
                <div class="footer">{app:footer()}</div>
            </div>
        </body>
    </html>

