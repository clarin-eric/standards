xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module" at "../modules/format.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: 
    @author margaretha
:)

<html lang="en">
    <head>
        <title>File Extensions</title>
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
                    &gt; <a href="{app:link("views/list-extensions.xq")}">File Extensions</a>
                </div>
                <div class="title">File Extensions</div>
                <div>
                    <p>This is a provisional list of the file extensions registered with the particular formats.
                        The final section lists formats, for which file extensions have not been specified.</p>
                    <table>
                        <tr>
                            <th>Extension</th>
                            <th>Formats</th>
                        </tr>
                        {fm:list-extensions()}
                    </table>
                </div>
                
                <div>
                    <span class="heading">Formats without file extensions</span>
                    <ul style="padding:0px; margin-left:15px;">
                        {fm:get-formats-without-extensions()}
                    </ul>
                </div>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>