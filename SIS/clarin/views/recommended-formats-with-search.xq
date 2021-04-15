xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace rm = "http://clarin.ids-mannheim.de/standards/recommendation" at "../modules/recommendation.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";

let $center := request:get-parameter('center', '')
let $domain := request:get-parameter('domain', '')
let $recommendationType := request:get-parameter('type', '')
let $sortBy := request:get-parameter('sortBy', '')
let $export := request:get-parameter('exportButton', '')
let $recommendationTable := rf:print-recommendation($center,$domain, $recommendationType, $sortBy)

return
if ($export)
then (rf:export-table($recommendationTable,"format-recommendation.xml"))
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
                            functions that the deposited data can play.</p>
                        <p>Use the dropboxes to select the particular domain and/or level of recommendation. The functionality to sort by columns is forthcoming.</p></div>
                    <div style="margin-top:30px;">
                        <form id="searchRecommendation" method="post" action="{app:link("views/recommended-formats-with-search.xq?#searchRecommendation")}">
                            <table>
                                <tr>
                                    <td>
                                        <select name="center" class="inputSelect" style="width:200px;">
                                            <option value="" selected="selected">Select centre ...</option>
                                            {rf:print-centers()}
                                        </select>
                                    </td>
                                    <td>
                                        <select name="domain" class="inputSelect" style="width:200px;">
                                            <option value="" selected="selected">Select domain ...</option>
                                            {rf:print-domains()}
                                        </select>
                                    </td>
                                    <td>
                                        <select name="type" class="inputSelect" style="width:200px;">
                                            <option value="" selected="selected">Select recommendation ...</option>
                                            <option value="1">recommended</option>
                                            <option value="2">acceptable</option>
                                            <option value="3">deprecated</option>
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
                            <input name="domain" type="hidden" value="{$domain}"/>
                            <input name="type" type="hidden" value="{$recommendationType}"/>
                            <input name="sortBy" type="hidden" value="{$sortBy}"/>
                        </form>
                    </div>
                    
                    <table id="recommendationTable" cellspacing="4px" style="width:97%">
                        <tr>
                            <th class="header" style="width:25%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=abbr&amp;domain=",
                                            $domain, "&amp;type=", $recommendationType, "#searchRecommendation"))
                                        }">Abbreviation</a>
                            </th>
                            <th class="header" style="width:25%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=centre&amp;domain=",
                                            $domain, "&amp;type=", $recommendationType, "#searchRecommendation"))
                                        }">Clarin Centres</a>
                            </th>
                            <th class="header" style="width:25%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=domain&amp;domain=",
                                            $domain, "&amp;type=", $recommendationType, "#searchRecommendation"))
                                        }">Domain</a></th>
                            <th class="header" style="width:25%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=recommendation&amp;domain=",
                                            $domain, "&amp;type=", $recommendationType, "#searchRecommendation"))
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

