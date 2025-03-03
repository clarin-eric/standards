xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace stm = "http://clarin.ids-mannheim.de/standards/statistics-module" at "../modules/statistics.xql";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace domain = "http://clarin.ids-mannheim.de/standards/domain" at "../model/domain.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: 
    @author margaretha
:)

let $reset := request:get-parameter('reset', '')
let $threshold := if ($reset) then (1) else request:get-parameter('threshold', 1)
let $top3 := if ($reset) then () else request:get-parameter('top3', '')
return


<html lang="en">
    <head>
        <title>Popular Formats</title>
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
                    &gt; <a href="{app:link("views/list-statistics.xq")}">Statistics</a>
                    &gt; <a href="{app:link("views/list-popular-formats.xq")}">Popular Formats</a>
                </div>
                <div class="title">Popular Formats</div>
                  <div>
                    <p>This section presents statistics concerning "popular" data deposition 
                    formats (however popularity can be defined) and should be considered work in progress. Feel welcome to add your suggestions to the 
                    <a href="https://github.com/clarin-eric/standards/issues/201">discussion at GitHub</a>. For a bit of inspiration, you might want 
                    to consult the page that is for now only made available to you, our 1-millionth viewer, and which visualises (at the bottom) our 
                    still skeletal and imperfectly implemented idea of 
                    <a href="{app:link("views/format-families.xq")}">format families</a>.</p>
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
                            <tr>
                                <td>
                                    <span class="tooltip">
                                        <input name="top3" class="button"
                                            style="margin:0;height:25px;width:260px;" type="submit" value="Most recommended formats"/>
                                    <span class="tooltiptext"
                                           style="width:300px; left:0%; top: 130%;">Show formats with the 3 highest numbers of recommendations
                                           </span>
                                    </span>
                                </td>
                                <td>
                                    <input name="reset" class="button"
                                        style="margin-bottom:5px;height:25px;" type="submit" value="Reset"/>
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
                        {   if ($top3) 
                            then stm:filterTop3Values()
                            else
                            stm:get-formats-per-domain($threshold)
                        }
                    </table>
                    
                    </div>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>
