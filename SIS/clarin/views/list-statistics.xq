xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";

import module namespace stm = "http://clarin.ids-mannheim.de/standards/statistics-module" at "../modules/statistics.xql";

import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace domain = "http://clarin.ids-mannheim.de/standards/domain" at "../model/domain.xqm";


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
                  <!--
                    <p>This section of the SIS is going to present various statistics concerning data deposition 
                    formats. Feel welcome to add your suggestions to the 
                    <a href="https://github.com/clarin-eric/standards/issues/67">discussion at GitHub</a>.</p>
                    -->
                  </div>
                    <div>
                    
                    <table style="width:500px">
                        <tr>
                            <th>Item</th>
                            <th style="width:150px">Total number</th>
                        </tr>
                        <tr>
                            <td>Formats</td>
                            <td style="text-align:right;">{count(format:get-all-ids())}</td>
                        </tr>
                        <tr>
                            <td>Domains</td>
                            <td style="text-align:right;">{count($domain:domains)}</td>
                        </tr>
                        <tr>
                            <td>Media types</td>
                            <td style="text-align:right;">{count(stm:getMimeTypes())}</td>
                        </tr>
                    </table>
                    
                    
                    <table style="width:500px">
                        <tr>
                            <th>Recommendation Level</th>
                            <th style="width:150px">Number of Formats</th>
                        </tr>
                        {stm:list-formats-by-recommendation-level()}
                    </table>
                    
                    <table style="width:500px">
                        <tr>
                            <th>Domain</th>
                            <th style="width:150px">Number of Formats</th>
                        </tr>
                        {stm:list-format-by-domain()}
                    </table>
                    
                    <table style="width:500px">
                        <tr>
                            <th>Media-types</th>
                            <th style="width:150px">Number of Formats</th>
                        </tr>
                        {stm:list-format-by-media-types()}
                    </table>
                    
                    
                    </div>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>