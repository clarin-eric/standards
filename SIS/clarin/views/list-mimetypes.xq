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
                    <p>This is a provisional list of the media types registered with the particular formats.
                        The final section lists formats, for which media types have not been specified.</p>
                    <table>
                        <tr>
                            <th>Mime-type</th>
                            <th>Formats</th>
                        </tr>
                        {fm:list-mime-types()}
                    </table>
                </div>
                <div>
                        <span class="heading">Formats without mime types</span>
                        <ul style="padding:0px; margin-left:15px;">
                            {fm:get-formats-without-mime-types()}
                        </ul>
                    </div>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>