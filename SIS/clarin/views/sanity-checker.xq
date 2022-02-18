xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace sc = "http://clarin.ids-mannheim.de/standards/sanity-checker" at "../modules/sanity-checker.xql";

(: 
    @author margaretha
:)

<html>
    <head>
        <title>Recommendation sanity checker</title>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        <script type="text/javascript" src="{app:resource("edit.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("utils.js", "js")}"/>
    </head>
    <body>
        <div id="all">
            <div class="logoheader"/>
            {menu:view()}
            <div class="content">
                <div class="navigation">
                    &gt; <a href="{app:link("views/sanity-checker.xq")}">Recommendation Sanity Checker</a>
                </div>
                
                <div class="title">Sanity checker for recommendation files</div>
                <div>
                    <p>The role of this page is to signal potential and real problems that may have arisen 
                    in the process of compiling recommendations or describing formats, etc..</p>
                </div>
                
                {if (sc:get-recommendations-with-missing-or-unknown-domains()) then
                <div>
                    <h2>Recommendations with missing or invalid domains</h2>
                    {sc:get-recommendations-with-missing-or-unknown-domains()}
                </div>
                else ''}
                
                {if (sc:get-recommendations-with-missing-or-unknown-levels()) then
                <div>
                    <h2>Recommendations with missing or invalid levels</h2>
                    {sc:get-recommendations-with-missing-or-unknown-levels()}
                </div>
                else ''}
                
                {if (sc:get-similar-recommendations()) then
                <div>
                    <h2>Recommendations that are similar</h2>
                    <div>
                    <p>Note that especially in this case, the similarity may be intended. Sets of 'similar' recommendations are marked with a frame.</p>
                    </div>
                {sc:get-similar-recommendations()}
                </div>
                else ''}
                </div>
            <div
                class="footer">{app:footer()}</div>
        </div>
    </body>
</html>