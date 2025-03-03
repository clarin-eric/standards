xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module" at "../modules/format.xql";
import module namespace stm = "http://clarin.ids-mannheim.de/standards/statistics-module" at "../modules/statistics.xql";

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
        <title>Media Types</title>
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
                    &gt; <a href="{app:link("views/list-mimetypes.xq")}">Media Types</a>
                </div>
                <div class="title">Media Types</div>
                <div>
                    <p>This is a list of media types registered with the particular formats. Altogether, the SIS mentions {count(stm:getMimeTypes())} media types 
                    (which are also, somewhat incorrectly but oh so commonly, called MIME types). The final section on this page lists formats, for which media types have not been specified.</p>
                    <table>
                        <tr>
                            <th>Media type</th>
                            <th>Formats</th>
                        </tr>
                        {fm:list-mime-types()}
                    </table>
                </div>
                <div>
                        <span class="heading">Formats for which media types are not listed</span>
                        <p>(Please kindly let us know if, below, you see a format that does have a corresponding media type.)</p>
                        <ul style="padding:0px; margin-left:15px;">
                            {fm:get-formats-without-mime-types()}
                        </ul>
                    </div>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>