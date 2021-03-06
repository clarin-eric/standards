xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace rm = "http://clarin.ids-mannheim.de/standards/recommendation" at "../modules/recommendation.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";

let $center := request:get-parameter('center', '')
let $domainId := request:get-parameter('domain', '')
let $recommendationType := request:get-parameter('type', '')
let $sortBy := request:get-parameter('sortBy', '')
let $export := request:get-parameter('exportButton', '')
let $recommendationTable := rf:print-recommendation($center,$domainId, $recommendationType, $sortBy)

return
if ($export)
then (rf:export-table($center, $domainId, $recommendationType, $recommendationTable,"format-recommendation.xml"))
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
                        &gt; <a href="{app:link("views/recommended-formats-with-search.xq")}">Recommended Formats</a>
                    </div>
                    <div class="title">CLARIN Format Recommendations</div>
                    
                    <div><p>This page presents formats of data depositions that various CLARIN centres are ready to accept. Each format,
                            for each centre, can be recommended, acceptable or deprecated in the context of several domains that represent the
                            functions that the deposited data can play.</p> <!-- TODO: a link to a separate piece of documentation on the domains, when that page exists -->
                        <p>Use the dropboxes to select the particular domain, centre, and/or level of recommendation. Columns can be sorted, 
                           and your results can be downloaded as XML.</p></div>
                    <div style="margin-top:30px;">
                        <form id="searchRecommendation" method="post" action="{app:link("views/recommended-formats-with-search.xq?#searchRecommendation")}">
                            <table>
                                <tr>
                                    <td>
                                        <select name="center" class="inputSelect" style="width:200px;">
                                            {rf:print-option($center, "", "Select centre ...")}
                                            {rf:print-centers($center)}
                                        </select>
                                    </td>
                                    <td>
                                        <select name="domain" class="inputSelect" style="width:200px;">
                                            {rf:print-option($domainId, "", "Select domain ...")}
                                            {rf:print-domains($domainId)}
                                        </select>
                                    </td>
                                    <td>
                                        <select name="type" class="inputSelect" style="width:200px;">
                                            {rf:print-option($recommendationType, "", "Select recommendation ...")}
                                            {rf:print-option($recommendationType, "1", "recommended")}
                                            {rf:print-option($recommendationType, "2", "acceptable")}
                                            {rf:print-option($recommendationType, "3", "deprecated")}
                                        </select>
                                    </td>
                                    <td>
                                        <input name="searchButton" class="button" style="margin-bottom:5px;height:25px;" type="submit" value="Search"/>
                                    </td>
                                </tr>
                            </table>
                        </form>
                        <form method="get" action="" style="text-align:right;">
                            <input name="exportButton" class="button" style="margin-bottom:5px;height:25px;width:150px;" type="submit" value="Export Table to XML"/>
                            <input name="center" type="hidden" value="{$center}"/>
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
                                            $domainId, "&amp;type=", $recommendationType, "&amp;center=",$center, "#searchRecommendation"))
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
                                            $domainId, "&amp;type=", $recommendationType, "&amp;center=",$center,"#searchRecommendation"))
                                        }">Domain</a></th>
                            <th class="header" style="width:20%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=recommendation&amp;domain=",
                                            $domainId, "&amp;type=", $recommendationType, "&amp;center=",$center,"#searchRecommendation"))
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

