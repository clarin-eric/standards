xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace rm = "http://clarin.ids-mannheim.de/standards/recommendation" at "../modules/recommendation.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";

let $domain := request:get-parameter('domain', '')
let $recommendationType := request:get-parameter('type', '')
return
    
    <html>
        <head>
            <title>CLARIN Format Recommendations</title>
            <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        </head>
        <body>
            <div id="all">
                <div class="logoheader"/>
                {menu:view()}
                <div class="content">
                    <div class="navigation">
                        &gt; <a href="{app:link("views/recommended-formats-with-search.xq")}">Recommended Formats</a>
                    </div>
                    <div class="title">CLARIN Format Recommendations</div>
                    <div><p>some description ?</p></div>
                    <div style="margin-top:30px; margin-bottom:20px;">
                        <form id="searchRecommendation" method="post" action="">
                        <table>
                            <tr>
                                <td>
                                    <select name="domain" class="inputSelect" style="width:200px;">
                                        <option value="" selected="selected">Select domain ...</option>
                                        {rf:print-domains()}
                                    </select>
                                </td>
                                <td>
                                    <select name="type" class="inputSelect" style="width:200px;">
                                        <option value="" selected="selected">Select recommendation ...</option>
                                        <option value="1">recommended</option>
                                        <option value="2">acceptable</option>
                                        <option value="3">deprecated</option>
                                    </select>
                                </td>
                                <td>
                                    <input name="searchButton" class="button" style="margin-bottom:5px;height:25px;" type="submit" value="Search"/>
                                </td>
                            </tr>
                        </table>
                        </form>
                    </div>
                    
                    <table cellspacing="4px" style="width:97%">
                        <tr>
                            <th class="header" style="width:25%;">Abbreviation</th>
                            <th class="header" style="width:25%;">Clarin Centers</th>
                            <th class="header" style="width:25%;">Domain</th>
                            <th class="header" style="width:25%;">Recommendation</th>
                        </tr>
                        {rf:print-recommendation($domain, $recommendationType)}
                    </table>
                </div>
                <div class="footer">{app:footer()}</div>
            </div>
        </body>
    </html>