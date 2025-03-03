xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace sc = "http://clarin.ids-mannheim.de/standards/sanity-checker" at "../modules/sanity-checker.xql";
import module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module" at "../modules/format.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: 
    @author margaretha
:)

let $sortBy := request:get-parameter('sortBy', '')

let $recommendations-strange-domains := sc:get-recommendations-with-missing-or-unknown-domains()
let $recommendations-strange-levels := sc:get-recommendations-with-missing-or-unknown-levels()
let $similar-recommendations := sc:get-similar-recommendations()

let $missingFormats := fm:list-missing-format-ids($sortBy)
let $numOfMissingFormats :=  count($missingFormats)
let $centresWithMissingFormats := fm:list-centre-with-missing-formats()
    
return

<html lang="en">
    <head>
        <title>Sanity check</title>
        <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        <script type="text/javascript" src="{app:resource("edit.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("utils.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
    </head>
    <body>
        <div id="all">
            <div class="logoheader"/>
            {menu:view()}
            <div class="content">
                <div class="navigation">
                    &gt; <a href="{app:link("views/recommended-formats-with-search.xq")}">Format Recommendations</a>
                    &gt; <a href="{app:link("views/sanity-check.xq")}">Sanity Check</a>
                </div>
                
                <div class="title">SIS sanity check</div>
                <div>
                    <p>The role of this page is to signal potential and real problems that may have arisen 
                    in the process of compiling recommendations or describing formats, etc. Feel welcome 
                    to <a href="https://github.com/clarin-eric/standards/issues/115">share your ideas</a> 
                    on what else may be useful here.</p>
                    <p>Note that a summary of <a href="{app:link("views/sanity-check-keywords.xq")}">keywords used in format descriptions</a> 
                    is provided on a separate page.</p>
                </div>
                
                <div id="missing">
                    <h2>List of missing format descriptions ({$numOfMissingFormats}): </h2>
                    <p>The formats listed below are referenced by recommendations, but not yet described <a href="{app:link("views/list-formats.xq")}">inside the SIS</a>. 
                    Clicking on a format name below opens a list of centres whose recommendations reference that format. The number of such centres is shown in brackets. 
                    Clicking on the ⊕ character opens a pre-configured GitHub issue where you can suggest the content of the format description. Clicking on the 
                    <img src="{app:resource("copy.png","image")}" width="12" /> symbol copies the format ID, e.g. to be used in editing format recommendations.</p>
                    <p>The list is also part of the sanity checking functionality: it may happen that some recommendation has a typo in the format ID, and then it 
                    will show up here.</p>
                    
                    <p> 
                        <form id ="missing-form" action="{app:link("views/sanity-check.xq?#missing-form")}">
                            <button name="sortBy" class="button" style="margin-right:15px;height:30px;width:200px;" 
                                type="submit" value= "id">Sort by Format Ids </button>
                            <button name="sortBy" class="button" style="margin:0;height:30px;width:300px;" 
                                type="submit" value= "recommendation">Sort by Number of Recommendations</button>
                         </form>
                    </p>
                    
                    <div style="column-count: 3;">
                        <ul style="margin: 0; padding-left:15px;">
                            {$missingFormats}
                        </ul>
                    </div>
                    
                    <h2>List of centres with missing format descriptions ({count($centresWithMissingFormats)}): </h2>
                    
                    <p> Below is a list of centres with references to non-existent formats. The number of missing formats is shown in parantheses. 
                        The list is sorted in descending order, starting with the centres having the greatest number of missing formats.</p>
                    <div style="column-count: 3;">
                        <ul style="margin: 0; padding-left:15px;">{$centresWithMissingFormats}</ul>
                    </div>
                    
                </div>
                <div id="unreferenced">
                    <h2>Existing format descriptions not referenced by any recommendation ({fm:count-orphan-format-ids()}): </h2>
                    <p>Note that membership in this list does not automatically indicate an error. Recommendations may change and leave "stray" 
                       formats unused, and we may sometimes want to merely describe "unspecified" versions of formats, while their 
                       particular variants are used in recommendations (because finer granularity is nearly always better).</p>
                    <div style="column-count: 3;">
                        <ul style="margin: 0; padding-left:15px;">
                            {fm:list-orphan-format-ids()}
                        </ul>
                    </div>
                </div>
                
                {if ($recommendations-strange-domains) then
                <div>
                    <h2>Recommendations with missing or invalid domains</h2>
                    {$recommendations-strange-domains}
                </div>
                else ''}
                
                {if ($recommendations-strange-levels) then
                <div>
                    <h2>Recommendations with missing or invalid levels</h2>
                    {$recommendations-strange-levels}
                </div>
                else ''}
                
                {if ($similar-recommendations) then
                <div>
                    <h2>Recommendations that are similar</h2>
                    <div>
                    <p>Note that, especially in this case, the similarity may be intended. Sets of 'similar' 
                    recommendations are marked with a frame.</p>
                    </div>
                {$similar-recommendations}
                </div>
                else ''}
                </div>
            <div
                class="footer">{app:footer()}</div>
        </div>
    </body>
</html>