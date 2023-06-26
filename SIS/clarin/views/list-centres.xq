xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module" at "../modules/centre.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";

let $reset := request:get-parameter('reset', '')
let $status := if ($reset) then () else request:get-parameter('status', '')
let $sortBy := if ($reset) then () else request:get-parameter('sortBy', '')
let $riCookie :=  request:get-cookie-value("ri")

return
    
    <html>
        <head>
            <title>Centres</title>
            <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
            <script type="text/javascript" src="{app:resource("edit.js", "js")}"/>
            <script type="text/javascript" src="{app:resource("session.js", "js")}"/>"/>
        </head>
        <body>
            <div id="all">
                <div class="logoheader"/>
                {menu:view()}
                <div class="content">
                    <div class="navigation">
                        &gt; <a href="{app:link("views/list-centres.xq")}">Centres</a>
                    </div>
                    <div class="title">Centres</div>
                    <div>
                    <p>This page lists centres encoded in the SIS, together with their status. For CLARIN centres, B-centres and 
                    centres with the status 'aiming for B' should in most cases be expected to maintain their format 
                    recommendations in the SIS.</p>
                    </div>
                    <div>
                        <form id="filterCentre" method="get" action="">
                            <table style="margin:0;">
                                <tr>
                                    <td>
                                        <select name="status" class="inputSelect" style="width:185px;">
                                            {rf:print-option("select", "", "Select status ...")}
                                            {cm:print-statuses($status)}
                                        </select>
                                    </td>
                                    <td>
                                        <input name="submit" class="button"
                                            style="margin:0;height:25px;" type="submit" value="Filter"/>
                                    </td>
                                    <td>
                                        <input name="reset" class="button"
                                            style="margin-bottom:5px;height:25px;" type="submit" value="Reset"/>
                                    </td>
                                </tr>
                            </table>
                        </form>
                    </div>
                    <table>
                        <tr>
                            <th class="header" style="width:20%;"><a href="?sortBy=id">ID</a></th>
                            <th class="header" style="width:40%;"><a href="?sortBy=name">Name</a></th>
                            <th class="header" style="width:40%;">Research Infrastructure
                                <!--<a href="?sortBy=ri">Research Infrastructure</a>-->
                            </th>
                            <!-- <th class="header" style="width:20%;">Status</th> -->
                        </tr>
                        {cm:list-centre($sortBy, $status, $riCookie)}
                    </table>
                </div>
                <div class="footer">{app:footer()}</div>
            </div>
        </body>
    </html>