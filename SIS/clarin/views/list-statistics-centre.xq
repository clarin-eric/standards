xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace stm = "http://clarin.ids-mannheim.de/standards/statistics-module" at "../modules/statistics.xql";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace domain = "http://clarin.ids-mannheim.de/standards/domain" at "../model/domain.xqm";

(: 
    @author margaretha
:)

<html>
    <head>
        <title>Centre Statistics</title>
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
                    &gt; <a href="{app:link("views/list-statistics.xq")}">Statistics</a>
                    &gt; <a href="{app:link("views/list-statistics-formats.xq")}">Centre Statistics</a>
                </div>
                <div class="title">Centre Statistics</div>
                    
                    <table style="width:600px">
                        <tr>
                            <th style="width:100px">RI</th>
                            <th >Number of Centres</th>
                            <th >Number of Depositing Centres</th>
                            <th>Number of Curated Centres</th>
                        </tr>
                        {stm:list-all-centre-statistics()}
                        {stm:list-centre-statistics()}
                    </table>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>
