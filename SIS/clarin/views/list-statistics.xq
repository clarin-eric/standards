xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace stm = "http://clarin.ids-mannheim.de/standards/statistics-module" at "../modules/statistics.xql";
import module namespace fm = "http://clarin.ids-mannheim.de/standards/format-module" at "../modules/format.xql";
import module namespace domain = "http://clarin.ids-mannheim.de/standards/domain" at "../model/domain.xqm";

(: 
    @author margaretha
:)

let $domainSortBy :=  request:get-parameter('domainSortBy', '')
return

<html>
    <head>
        <title>Statistics</title>
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
                </div>
                <div class="title">Statistics</div>
                  <div>
                    <p>This section presents various format-related statistics and is still work in progress. Feel welcome to add your suggestions as a 
                    <a href="https://github.com/clarin-eric/standards/issues/new?assignees=&amp;labels=SIS:enhancement&amp;title=Idea for the statistics page">GitHub issue</a>.
                    Note that <a href="{app:link("views/list-statistics-centre.xq")}">centre-related statistics</a> are listed separately.</p>
                  </div>
                    <div>
                    
                    <table style="width:500px">
                        <tr>
                            <th>Item</th>
                            <th style="width:150px">Total number</th>
                        </tr>
                        <tr>
                            <td>Formats individually recorded in the SIS</td>
                            <td style="text-align:right;">{fm:count-defined-formats()}</td>
                        </tr>
                        <tr>
                            <td>All formats mentioned in the SIS</td>
                            <td style="text-align:right;">{fm:count-defined-formats() + fm:count-missing-format-ids()}</td>
                        </tr>
                        <tr>
                            <td>Functional domains</td>
                            <td style="text-align:right;">{count($domain:domains)}</td>
                        </tr>
                        <tr>
                            <td>Media types</td>
                            <td style="text-align:right;">{count(stm:getMimeTypes())}</td>
                        </tr>
                    </table>
                    
                    <div style="width:500px;margin-bottom:40px">
                        <p>Above, the first row counts all the formats that have a corresponding information file in the SIS. 
                        More information about them is provided in the <a href="{app:link("views/list-formats.xq")}">Data Deposition Formats</a> section.</p>
                        <p>The second row counts all formats mentioned by the recommendations, and that includes 
                        <a href="{app:link("views/sanity-check.xq#missing")}">formats that do not (yet) have a dedicated description file</a> in the SIS.</p>
                        <p><a href="{app:link("views/list-domains.xq")}">Functional domains</a> (see also immediately below) and <a href="{app:link("views/list-mimetypes.xq")}">media types</a> also have dedicated sections in the SIS.</p>
                        
                    </div>
                    
                    <table id = "domainTable" style="width:500px;margin-bottom:40px">
                        <tr>
                            <th><a href="{app:link("views/list-statistics.xq?domainSortBy=alphabet#domainTable")}">
                                Functional domain</a>
                            </th>
                            <th style="width:150px">
                                <a href="{app:link("views/list-statistics.xq?domainSortBy=number#domainTable")}">
                                Number of recommendations</a>
                            </th>
                        </tr>
                        {stm:list-format-by-domain($domainSortBy)}
                    </table>
                    
                    <table style="width:500px;margin-bottom:40px">
                        <tr>
                            <th>Level of recommendation</th>
                            <th style="width:150px">Number of recommendations</th>
                        </tr>
                        {stm:list-formats-by-recommendation-level()}
                    </table>
                    
                    
                    
                    <!--
                    <table style="width:500px">
                        <tr>
                            <th>Media-types</th>
                            <th style="width:150px">Number of Formats</th>
                        </tr>
                        {stm:list-format-by-media-types()}
                    </table>
                    -->
                    
                </div>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>
