xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";

let $reset := request:get-parameter('resetButton', '')
let $centre := if ($reset) then () else request:get-parameter('centre', '')
let $domainId := if ($reset) then () else request:get-parameter('domain', '')
let $recommendationLevel := if ($reset) then () else request:get-parameter('level', '')
let $sortBy := if ($reset) then () else request:get-parameter('sortBy', '')
let $export := request:get-parameter('export', '')
let $page := request:get-parameter('page', 1) 
let $rows := rf:print-centre-recommendation($centre,$domainId, $recommendationLevel, $sortBy)
let $recommendationTable := rf:paging($rows,$page)

return
if ($export)
then (rf:export-table($centre, $domainId, $recommendationLevel, $recommendationTable,
    "format-recommendation.xml","views/recommended-formats-with-search.xq"))
else 

    <html>
        <head>
            <title>Format Recommendations</title>
            <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        </head>
        <body>
            <div id="all">
                <div class="logoheader"/>
                {menu:view()}
                <div class="content">
                    <div class="navigation">
                        &gt; <a href="{app:link("views/recommended-formats-with-search.xq")}">Format Recommendations</a>
                    </div>
                    <div class="title" id="pagetitle">Format Recommendations</div>
                    
                    <div><p>This page presents formats of data depositions that various CLARIN centres are ready to accept. Each format,
                            for each centre, can be "recommended", "acceptable" or "deprecated" in the context of several domains that represent the
                            functions that the deposited data can play. The level of recommendation should always be viewed as relative to the profile 
                            of the given centre.
                            <ul>
                            <li><b>"recommended"</b> should be interpreted as meaning that the centre in question will in most cases be able 
                            to process the data without much manipulation and that it is likely that the data will be preserved long-term 
                            in that format (the specifics are up to that centre);</li>
                            <li><b>"acceptable"</b> should be interpreted as meaning that the centre may need to spend some time and resources 
                            on the up-conversion of the data, and that the data may be preserved in one of the recommended formats instead;</li>
                            <li><b>"deprecated"</b> should be understood as indicating that the centre may find it problematic to up-convert the data.</li>
                            </ul>
                            </p> 
                        <p>Use the dropboxes to select the particular domain, centre, and/or level of recommendation. Columns can be sorted, 
                           and your results can be downloaded as XML.</p>
                           <p>The exported XML files for a specified centre can be used to extend or modify the recommendations for that centre, 
                           by an authorised person. In order to aid in the process, please consult the separate lists of all 
                           <a href="{app:link("views/list-formats.xq")}">available file formats</a> and of the 
                           functional groupings of formats (<a href="{app:link("views/list-domains.xq")}">functional domains</a>).</p>
                           
                           <p>As of mid-2022, not every centre with depositing services has submitted the information to the SIS; in some cases, the information 
                           had to be unreliably mapped from lists provided on centre homepages onto the feature matrix offered by the SIS (created on the basis 
                           of the SIS functional domains and levels of recommendation). If you think you see an error, please 
                           <a href="https://github.com/clarin-eric/standards/wiki/Updating-format-recommendations">kindly help us get it right</a>.</p></div>
                    <div style="margin-top:30px;">
                        <form id="searchRecommendation" style="float:left;" method="get" action="{app:link("views/recommended-formats-with-search.xq?#searchRecommendation")}">
                            <table style="margin:0;">
                                <tr>
                                    <td>
                                        <select name="centre" class="inputSelect" style="width:185px;">
                                            {rf:print-option($centre, "", "Select centre ...")}
                                            {rf:print-centres($centre)}
                                        </select>
                                    </td>
                                    <td>
                                        <select name="domain" class="inputSelect" style="width:185px;">
                                            {rf:print-option($domainId, "", "Select domain ...")}
                                            {rf:print-domains($domainId)}
                                        </select>
                                    </td>
                                    <td>
                                        <select name="level" class="inputSelect" style="width:190px;">
                                            {rf:print-option($recommendationLevel, "", "Select recommendation ...")}
                                            {rf:print-option($recommendationLevel, "recommended", "recommended")}
                                            {rf:print-option($recommendationLevel, "acceptable", "acceptable")}
                                            {rf:print-option($recommendationLevel, "deprecated", "deprecated")}
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
                            <input name="export" class="button"
                            style="margin-bottom:5px; margin-right:2px; margin-top:20px; height:25px;width:165px;" type="submit" value="Export Table to XML"/>
                            <input name="centre" type="hidden" value="{$centre}"/>
                            <input name="domain" type="hidden" value="{$domainId}"/>
                            <input name="level" type="hidden" value="{$recommendationLevel}"/>
                            <input name="sortBy" type="hidden" value="{$sortBy}"/>
                        </form>
                    </div>
                    
                    <table id="recommendationTable" style="width:97%">
                        <tr>
                            <th class="header" style="width:19%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=abbr&amp;domain=",
                                            $domainId, "&amp;level=", $recommendationLevel, "&amp;centre=",$centre, "#searchRecommendation"))
                                        }">Format</a>
                            </th>
                            <th class="header" style="width:19%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=centre&amp;domain=",
                                            $domainId, "&amp;level=", $recommendationLevel, "&amp;centre=",$centre, "#searchRecommendation"))
                                        }">Clarin Centres</a>
                            </th>
                            <th class="header" style="width:40%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=domain&amp;domain=",
                                            $domainId, "&amp;level=", $recommendationLevel, "&amp;centre=",$centre,"#searchRecommendation"))
                                        }">Domain</a></th>
                            <th class="header" style="width:19%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=recommendation&amp;domain=",
                                            $domainId, "&amp;level=", $recommendationLevel, "&amp;centre=",$centre,"#searchRecommendation"))
                                        }">
                                    Recommendation</a></th>
                            <th style="border-bottom-style:none;"></th>
                        </tr>
                        {$recommendationTable}
                    </table>
                    <div style="text-align:right; margin-right:40px;">{rf:print-page-links(count($rows),$sortBy,$domainId,$recommendationLevel,$centre,$page)}</div>
                </div>
                <div class="footer">{app:footer()}</div>
            </div>
        </body>
    </html>

