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

let $reset := request:get-parameter('reset', '')
let $threshold := if ($reset) then (1) else request:get-parameter('threshold', 1)
return


<html>
    <head>
        <title>Popular Formats</title>
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
                    &gt; <a href="{app:link("views/list-popular-formats.xq")}">Popular Formats</a>
                </div>
                <div class="title">Popular Formats</div>
                  <div>
                    <p>This section presents statistics concerning popular data deposition 
                    formats and is still work in progress. Feel welcome to add your suggestions to the 
                    <a href="https://github.com/clarin-eric/standards/issues/67">discussion at GitHub</a>.</p>
                  </div>
                    <div>
                    
                    <form method="get" action="">
                        <table style="margin:0;">
                            <tr>
                                <td><span>Minimum number of recommendations</span>: </td>
                                <td>
                                   <input name="threshold" style="margin-left:2px; width:70px;" value="{$threshold}"></input>
                                </td>
                                <td>
                                    <input name="submit" class="button"
                                        style="margin:0;height:25px;" type="submit" value="Filter"/>
                                </td>
                            </tr>
                        </table>
                    </form>
                    
                    <table style="width:600px">
                        <tr>
                            <th>Domain</th>
                            <th>Format</th>
                            <th style="width:150px">Number of Recommendations</th>
                        </tr>
                        {   
                            stm:get-formats-per-domain($threshold)
                        }
                    </table>
                    
                    </div>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>
