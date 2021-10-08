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
        <title>Data Deposition Formats</title>
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
                </div>
                <div class="title">Data Deposition Formats</div>
                  <div>
                    <p>This page lists formats used in the recommendations for data deposition formats. The list is still incomplete.</p>
                    <p>The name of the format links to its description, sometimes rather stubby (you are welcome to help us extend the list 
                    and/or the descriptions, either by submitting an issue at GitHub containing suggested text or corrections, or by editing 
                    or adding the relevant format file and submitting a pull request).</p>
                    <p>By clicking on the icon next to the format name, it is possible to copy the format ID, 
                    useful for editing or adding centre recommendations.</p>
                  </div>
                <ul style="padding:0px; margin-left:15px;">
                    {fm:list-formats()}
                </ul>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>