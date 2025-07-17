xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";
import module namespace em = "http://clarin.ids-mannheim.de/standards/export" at "../modules/export.xql";
import module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module" at "../modules/centre.xql";
import module namespace web = "https://clarin.ids-mannheim.de/standards/web" at "../model/web.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

let $searchItem := request:parameter('searchFormat', '')

let $reset := request:parameter('resetButton', '')
let $centre := if ($reset) then () else request:parameter('centre', '')
let $domainId := if ($reset) then (()) else request:parameter('domain',())
let $domainParams := fn:string-join(for $d in $domainId return ("&amp;domain=",$d))

let $recommendationLevel := if ($reset) then () else request:parameter('level', '')
let $sortBy := if ($reset) then () else request:parameter('sortBy', '')
let $page := request:parameter('page', 1) 
(: let $language := fn:substring(request:header("Accept-Language"),0,3) :)

let $ri := app:get-ri()
let $language := app:determine-language($ri)

let $rows :=
     rf:print-centre-recommendation($centre,$domainId, $recommendationLevel, 
     $sortBy, $language, $ri)

let $rows := 
    if ($searchItem)
    then rf:searchFormat($searchItem,$rows)
    else $rows

let $recommendationTable := rf:paging($rows,$page)

let $numberOfPages := xs:integer(fn:ceiling(count($rows) div $rf:pageSize))

return

    <html lang="en">
        <head>
            <title>Format Recommendations</title>
            <link rel="icon" type="image/x-icon" href="../resources/images/SIS-favicon.svg"/>
            <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
            <link rel="stylesheet" type="text/css" href="{app:resource("autocomplete.css", "css")}"/>
            <script type="text/javascript" src="{app:resource("autocomplete.js", "js")}"/>
            <script type="text/javascript" src="{app:resource("multiselect-dropdown.js", "js")}"/>
            <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
            <script>
            var searchSuggestion = '{rf:listSearchSuggestions($rows)}';
            
            document.addEventListener('DOMContentLoaded', function() {{
                window.onload = init();
            }});
        
             function init(){{
                 checkActiveRI();
                 suggestion('searchId', searchSuggestion)
             }}
           
        </script>
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
                    <div>
                        <p>Each centre listed in the SIS as allowing/inviting data deposition has a certain set of preferences and expectations 
                    concerning the data to be stored with it. This page provides a lengthy list of preferences that can be appropriately cut down 
                    to a manageable size by means of filter criteria.</p> 
                        <p>Use the dropboxes to select the particular domain, centre, and/or level of recommendation. Columns can be sorted, 
                           and your results can be downloaded as XML. Search can be narrowed to a single research infrastructure through the top menu.</p>
                        <p>Each format,
                            for each centre, can be "recommended", "acceptable" or "discouraged" in the context of several domains that represent the
                            functions that the deposited data is meant to play. The level of recommendation should always be viewed as relative to the profile of 
                            the given centre, along the following rules of thumb:
                            <ul>
                            <li><b>"recommended"</b> should be interpreted as meaning that the centre in question will in most cases be able 
                            to process the data without much manipulation and that it is likely that the data will be preserved long-term 
                            in that format (the specifics are up to that centre);</li>
                            <li><b>"acceptable"</b> should be interpreted as meaning that the centre may need to spend some time and resources 
                            on the up-conversion of the data, and that the data may be preserved in one of the recommended formats instead;</li>
                            <li><b>"discouraged"</b> should be understood as indicating that the centre may find it problematic to up-convert the data.</li>
                            </ul>
                            </p> 
    
                            <p>Many of the <a href="{app:link("views/list-formats.xq")}">data formats</a> mentioned below have dedicated description files. 
                            Those that don't are marked with a circled plus. <a href="{app:link("views/list-domains.xq")}">Functional domains</a> specify the role
                            that the deposited data can play. (Is it documentation, audio signal, or textual annotation? Etc.) Hover the mouse cursor over a domain name
                            for a brief gloss. Hover over circled "i"s to read comments.</p>
                           
                           <p>If you think you see an error, please kindly help us get it right, by 
                           <a title="open a new GitHub issue" href="{concat('https://github.com/clarin-eric/standards/issues/new?assignees=&amp;labels=centre+data%2C+templatic%2C+UserInput&amp;template=incorrect-missing-centre-recommendations.md&amp;title=Fix needed in the list of recommendations',', webCommitId=', web:get-short-commitId()) }">posting an issue</a> or 
                           <a title="consult the SIC wiki at GitHub" href="https://github.com/clarin-eric/standards/wiki/Updating-format-recommendations">editing the source</a>.</p></div>
                    <div style="margin-top:30px;">
                        <form id="filterRecommendation"  autocomplete="off" style="float:left;" method="get"
                            action="{app:link("views/recommended-formats-with-search.xq?#filterRecommendation")}">
                            <table style="margin:0; border: solid 1px #c0c0c0; border-radius:4px;padding:5px;background-color:#c3d3e3;">
                                <tr >
                                    <td width="180px;" >
                                        <select name="centre" class="inputSelect" style="width:290px;height:30px;padding:5px;background-color:white;">
                                            {rf:print-option("select", "", "Select centre ...")}
                                            {rf:print-centres($centre,$ri)}
                                        </select>
                                    </td>
                                    
                                    <td>
                                        <select name="level" class="inputSelect" style="width:290px;height:30px;padding:5px;background-color:white;">
                                            {rf:print-option("select", "", "Select recommendation ...")}
                                            {rf:print-option($recommendationLevel, "recommended", "recommended")}
                                            {rf:print-option($recommendationLevel, "acceptable", "acceptable")}
                                            {rf:print-option($recommendationLevel, "discouraged", "discouraged")}
                                        </select>
                                    </td>
                                    
                                </tr>
                                <tr>
                                <td>
                                        <select name="domain" class="inputSelect" style="width:278px;margin:0;" 
                                            multiple="multiple" placeholder="Select domain ...">
                                            <!-- {rf:print-option("select", "", "Select domain ...")} -->
                                            {rf:print-domains($domainId)}
                                        </select>
                                    </td>
                                    <td style="vertical-align:top">
                                        <input name="filterButton" class="button"
                                        style="margin:0;height:30px;" type="submit" value="Filter"/>
                                        <input name="resetButton" class="button"
                                        style="margin:0 0 0 1px;height:30px;" type="submit" value="Reset"/>
                                    </td>
                                </tr>
                            </table>
                        </form>
                    </div>
                    
                    <table style="margin-left: 10px;" >
                        <tr>
                            <td>
                                <form id="searchRecommendation"  autocomplete="off" style="margin:10px 0 10px 0;
                                    border: solid 1px #c0c0c0; border-radius:4px;padding:5px;background-color:#c3d3e3;width:590px" 
                                    method="get"
                                    action="{app:link("views/recommended-formats-with-search.xq?#filterRecommendation")}">
                                    <div class ="autocomplete">
                                            <input id="searchId" name="searchFormat" style="width:400px;height:26px;padding-left:5px" 
                                                class="inputText" type="text" 
                                                placeholder="Search format ..." value="{$searchItem}"/>
                                    </div>
                                     <input name="searchButton" class="button"
                                                style="margin: 0 0 0 3px;height:30px; vertical-align:middle;" 
                                                type="submit" value="Search"/>
                                     <input name="centre" type="hidden" value="{$centre}"/>
                                    {
                                        for $id in $domainId
                                        return
                                        <input name="domain" type="hidden" value="{$id}"/>
                                    }
                                    <input name="level" type="hidden" value="{$recommendationLevel}"/>
                                    <input name="sortBy" type="hidden" value="{$sortBy}"/>           
                                </form>
                            </td>
                            <td style="padding-left:5px;">
                                <form method="get" action="export.xq" style="text-align:right;">
                                    <input name="export" class="button"
                                        style="margin-bottom:5px; margin-right:2px; 
                                        height:30px;width:165px;" type="submit" value="Export Table to XML"/>
                                    <input name="centre" type="hidden" value="{$centre}"/>
                                    {
                                        for $id in $domainId
                                        return
                                        <input name="domain" type="hidden" value="{$id}"/>
                                    }
                                    <input name="level" type="hidden" value="{$recommendationLevel}"/>
                                    <input name="sortBy" type="hidden" value="{$sortBy}"/>
                                    <input name="searchFormat" type="hidden" value="{$searchItem}"/>
                                    <input name="source" type="hidden" value="views/recommended-formats-with-search.xq"/>
                                </form>
                            </td>
                        </tr>
                    </table>
                        
                    <table id="recommendationTable" style="width:98%;">
                        <tr>
                            <th class="header" style="width:19%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=abbr",
                                            $domainParams, "&amp;level=", $recommendationLevel, "&amp;centre=",$centre, "#searchRecommendation"))
                                        }">Format</a>
                            </th>
                            <th class="header" style="width:19%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=centre",
                                            $domainParams, "&amp;level=", $recommendationLevel, "&amp;centre=",$centre, "#searchRecommendation"))
                                        }">Centre</a>
                            </th>
                            <th class="header" style="width:40%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=domain",
                                            $domainParams, "&amp;level=", $recommendationLevel, "&amp;centre=",$centre,"#searchRecommendation"))
                                        }">Domain</a></th>
                            <th class="header" style="width:19%;">
                                <a href="{
                                            app:link(concat("views/recommended-formats-with-search.xq?sortBy=recommendation",
                                            $domainParams, "&amp;level=", $recommendationLevel, "&amp;centre=",$centre,"#searchRecommendation"))
                                        }">
                                    Recommendation</a></th>
                            <th style="border-bottom-style:none;"></th>
                        </tr>
                        {$recommendationTable}
                    </table>
                    <div style="text-align:center;">{rf:print-page-navigation($numberOfPages ,$sortBy,$domainParams,
                        $recommendationLevel,$centre,$page)}</div>
                        
                </div>
                <div class="footer">{app:footer()}</div>
            </div>
        </body>
    </html>

