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
        <title>Keyword Check</title>
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
                    &gt; <a href="{app:link("views/similar-recommendation.xq")}">Keyword Check</a>
                </div>
                
                <div class="title">Keyword check</div>
                
                 <div id="keywords">
                    <h2>List of keywords</h2>
                        <ul>{sc:list-keywords()}</ul>
                </div>
                </div>
            <div
                class="footer">{app:footer()}</div>
        </div>
    </body>
</html>