xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module" at "../modules/format.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

let $reset := request:get-parameter('resetButton', '')
let $keyword := if ($reset) then () else request:get-parameter('keyword', '')
let $searchItem := if ($reset) then () else request:get-parameter('searchFormat', '')

return
(: 
    @author margaretha
:)

<html lang="en">
    <head>
        <title>Data Deposition Formats</title>
        <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("autocomplete.css", "css")}"/>
        <script type="text/javascript" src="{app:resource("edit.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("utils.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("autocomplete.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
        <script>
            var searchSuggestion = '{fm:list-search-suggestion()}';
            
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
                    &gt; <a href="{app:link("views/list-formats.xq")}">Data Deposition Formats</a>
                </div>
                <div class="title">Data Deposition Formats</div>
                <div>
                <p>The SIS does not restrict the content of recommendations to the range of formats actually described in the system -- centres can mention 
                any format that they are actually prepared to support, by creating and systematically using a format ID, which generally consists of the character 
                "f" followed by a potentially mnemonic name. In this way, two major classes of broadly understood formats must be distinguished: </p>
                <ul>
                <li>{fm:count-defined-formats()} formats that are part of the SIS inventory, equipped with descriptions, keywords, potentially references 
                to standards that define or use them, etc. Call these 'described formats'; they are listed at the bottom of this page;</li>
                <li>{fm:count-defined-formats() - fm:count-orphan-format-ids() + fm:count-missing-format-ids()} formats that are referenced inside centre recommendations, by means of an ID (call these 'referenced formats').</li>
                </ul>
                <p>(One might think that the two sets should be identical, but the aim of the SIS is to reflect the <i>current</i> recommendations, and
                        these are meant to be created in a dynamic fashion, as needed by centres and as dictated by the evolving technological context.)</p>
                
                <p>These two classes overlap, resulting in a tripartite division:</p>
                <ol>
                <li>the intersection of described formats and referenced formats: {fm:count-defined-formats() - fm:count-orphan-format-ids()} formats that are mentioned 
                in recommendations and are at the same time described in the SIS;</li>
                <li>referenced formats that are not (yet) described in the SIS ({fm:count-missing-format-ids()} 'missing formats'); they are the ones that have a "+" 
                symbol in recommendation lists and that link to predefined GitHub issues;</li>
                <li>formats that are described in the SIS but are not mentioned by any recommendation ({fm:count-orphan-format-ids()} 'orphaned formats'); these are mostly either "umbrella" format categories, 
                or formats once supported by centres but at least temporarily not in the scope of interest.</li>
                </ol>
                <p>The present page lists the described formats (categories 1 and 3 above), together with some of the properties that are identified in their descriptions. 
                Formats from categories 2 and 3 are listed separately at the <a href="{app:link("views/sanity-check.xq")}">sanity checker</a> page. Among the 
                described formats, umbrella formats are distinguished by a preceding icon depicting a tiny pink unicorn.</p>
                </div>
                <div id="defined">
                    <h2>Formats described in the SIS ({fm:count-defined-formats()})</h2>
                    <p>The name of the format links to its description, sometimes rather stubby (you are welcome to help us extend the list
                        and/or the descriptions, either by
                        <a href="{app:getGithubFormatIssueLink()}">submitting an issue at GitHub</a>
                        containing suggested text or corrections, or by editing or adding the relevant
                        <a href="https://github.com/clarin-eric/standards/tree/formats/SIS/clarin/data/formats">format file</a> and submitting a pull request).</p>
                    <p>The number in the brackets following the format name indicates how many recommendations target the given format. (Low numbers may be worth investigating.)</p>
                    <p>By clicking on the icon next to the format name, you can copy the format ID, which may be useful for editing or adding 
                       centre recommendations.</p>
                    
                       <form id="filter" method="get" action="{app:link("views/list-formats.xq#filter")}"
                            style="border: solid 1px #c0c0c0; border-radius:4px;padding:3px;
                            background-color:#c3d3e3;width:500px;">
                            <table style="margin:0;">
                                <tr>
                                    <td><!--<span class="heading3">Keyword</span>-->
                                        <select name="keyword" class="inputSelect" 
                                        style="width:308px;height:25px;background-color:white;padding:4px;
                                        margin-left:2px;">
                                            {rf:print-option("select", "", "Select keyword ...")}
                                            {rf:print-keywords($keyword)}
                                        </select>
                                    </td>
                                    <td>
                                        <input name="filterButton" class="button"
                                        style="margin:0;height:25px;" type="submit" value="Filter"/>
                                    </td>
                                    <td>
                                        <input name="resetButton" class="button"
                                        style="margin-bottom:5px;height:25px;" type="submit" value="Reset"/>
                                    </td>
                                </tr>
                                <tr>
                                <td class ="autocomplete">
                                         <input id="searchId" name="searchFormat" 
                                         style="width:300px;padding:4px 4px 0px 4px;" 
                                        class="inputText" type="text" 
                                        placeholder="Search format ..." value="{$searchItem}"/>
                                </td>
                                <td>
                                    <input name="searchButton" class="button"
                                    style="margin:0;height:25px;vertical-align:top;" type="submit" value="Search"/>
                                </td>
                                <td>
                                </td>
                            </tr>
                            </table>
                       </form>
                </div>
                <table>
                    <tr>
                        <th style="width:30%;min-width:180px">Format</th>
                        <th style="width:45%">MIME types</th>
                        <th style="width:25%">File Extensions</th>
                    </tr>
                    {fm:list-formats($keyword,$searchItem)}
                </table>
            </div>
            <div
                class="footer">{app:footer()}</div>
        </div>
    </body>
</html>