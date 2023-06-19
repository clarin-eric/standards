xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace sc = "http://clarin.ids-mannheim.de/standards/sanity-checker" at "../modules/sanity-checker.xql";
import module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module" at "../modules/format.xql";

(: 
    @author margaretha
:)

let $recommendations-strange-domains := sc:get-recommendations-with-missing-or-unknown-domains()
let $recommendations-strange-levels := sc:get-recommendations-with-missing-or-unknown-levels()
let $similar-recommendations := sc:get-similar-recommendations()
return

<html>
    <head>
        <title>Sanity check</title>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        <script type="text/javascript" src="{app:resource("edit.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("utils.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("session.js", "js")}"/>"/>
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
                </div>
                
                <div id="missing">
                    <h2>List of missing formats by ID ({fm:count-missing-format-ids()}): </h2>
                    <p>These formats are referenced by centre recommendations, but not yet described in the SIS. Clicking on an ID 
                    below will open a pre-configured GitHub issue where you can suggest the content of the format description.</p>
                    <p>The list is also part of the sanity checking functionality: it may happen that some recommendation has a 
                    typo in the format ID, and then it will show up here.</p>
                    <div>
                        <ul class="column" style="padding:0px; margin-left:15px;">
                            {fm:list-missing-format-ids()}
                        </ul>
                    </div>
                </div>
                <div id="unreferenced">
                    <h2>Existing format descriptions not referenced by any recommendation ({fm:count-orphan-format-ids()}): </h2>
                    <p>Note that membership in this list does not automatically indicate an error. Recommendations may change and leave "stray" 
                       formats unused, and we may sometimes want to merely describe "unspecified" versions of formats, while their 
                       particular variants are used in recommendations (because finer granularity is nearly always better).</p>
                    <div>
                        <ul class="column" style="padding:0px; margin-left:15px;">
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