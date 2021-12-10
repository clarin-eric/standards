xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module" at "../modules/centre.xql";

<html>
    <head>
        <title>Centres</title>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        <script type="text/javascript" src="{app:resource("edit.js", "js")}"/>
    </head>
    <body>
        <div id="all">
            <div class="logoheader"/>
            {menu:view()}
            <div class="content">
                <div class="navigation">
                    &gt; <a href="{app:link("views/list-centres.xq")}">Centres</a>
                </div>
                <div class="title">Centres</div>
                <table>
                    <tr>
                        <th class="header" style="width:20%;">ID</th>
                        <th class="header" style="width:40%;">Name</th>
                        <th class="header" style="width:20%;">Research Infrastructure</th>
                        <th class="header" style="width:20%;">Status</th>
                    </tr>
                    {cm:list-centre()}
                </table>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>