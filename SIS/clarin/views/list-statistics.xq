xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module" at "../modules/format.xql";

(: 
    @author margaretha, banski
:)

<html>
    <head>
        <title>Statistics</title>
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
                    &gt; <a href="{app:link("views/list-statistics.xq")}">Statistics</a>
                </div>
                <div class="title">Format Statistics</div>
                  <div>
                    <p>This section of the SIS is going to present various statistics concerning data deposition 
                    formats. Feel welcome to add your suggestions to the 
                    <a href="https://github.com/clarin-eric/standards/issues/67">discussion at GitHub</a>.</p>
                  </div>
                <div>
                <ul style="padding:0px; margin-left:15px;">
                
                </ul>
                </div>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>