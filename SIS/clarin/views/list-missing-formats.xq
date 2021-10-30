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
        <title>Missing Format Descriptions</title>
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
                    &gt; <a href="{app:link("views/list-formats.xq")}">Data Deposition Formats</a>
                    &gt; <a href="{app:link("views/list-missing-formats.xq")}">Missing Format Descriptions</a>
                </div>
                <div class="title">Missing Format Descriptions</div>
                  <div>
                    <p>This page lists formats that have not got any description yet, as well as formats where 
                       the name used in recommendations does not match the format description (or the format 
                       description is not present).</p>
                  </div>
                <div>
               <p class="heading">List of missing formats by id ({fm:count-missing-format-ids()}): </p>
                <ul class="column" style="padding:0px; margin-left:15px;">
                    {fm:list-missing-format-ids()}
                </ul>

                <p class="heading">List of format names used in recommendations that are not present in format descriptions: </p>
                <ul class="column" style="padding:0px; margin-left:15px;">
                    {fm:list-missing-format-abbrs()}
                </ul>
                </div>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>