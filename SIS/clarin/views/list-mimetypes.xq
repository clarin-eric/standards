xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module" at "../modules/format.xql";

(: 
    @author margaretha
:)

<html>
    <head>
        <title>Media Types</title>
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
                    &gt; <a href="{app:link("views/list-mimetypes.xq")}">Media Types</a>
                </div>
                <div class="title">Media Types</div>
                
                <div>
                <ul style="padding:0px; margin-left:15px;">
                    {fm:list-mime-types()}
                    {fm:get-formats-without-mime-types()}
                </ul>
                </div>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>