xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace sbm = "http://clarin.ids-mannheim.de/standards/sb-module" at "../modules/sb.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: Define the list of standard body page 
   @author margaretha
:)

<html lang="en">
    <head>
        <title>Standard Bodies</title>
        <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        <script type="text/javascript" src="{app:resource("edit.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
    </head>
    <body>
        <div id="all">
            <div class="logoheader"/>
            {menu:view()}
            <div class="content">
                <div class="navigation">
                    &gt; <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">Standards Watchtower</a>
                    &gt; <a href="{app:link("views/list-sbs.xq")}">Standard Bodies</a>
                </div>
                <div class="title">Standard Bodies</div>
                <div><p>Standard bodies are organizations that develop standards. </p></div>
                <ul style="padding:0px; margin-left:15px;">
                    {sbm:list-sbs()}
                </ul>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>