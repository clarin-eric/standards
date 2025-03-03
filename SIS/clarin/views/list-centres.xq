xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module" at "../modules/centre.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

let $reset := request:get-parameter('reset', '')
let $status := if ($reset) then () else request:get-parameter('status', '')
let $sortBy := if ($reset) then () else request:get-parameter('sortBy', '')
let $riCookie :=  request:get-cookie-value("ri")

return
    
    <html lang="en">
        <head>
            <title>Centres</title>
            <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
            <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
            <script type="text/javascript" src="{app:resource("edit.js", "js")}"/>
            <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
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
                    <p>This page lists centres encoded in the SIS, together with their status. Among the 
                    <a href="https://centres.clarin.eu/">CLARIN centres</a>, B-centres and 
                    numerous C-centres provide data deposition services. It is a safe assumption that centres belonging to other 
                    research infrastructures that are listed here also provide depositing services, but that feature may change in time 
                    and this is why there is a separate column indicating the 'depositing' status.</p>
                    <p>While the ideal situation would be one where all depositing centres maintain their recommendations in the SIS, in 
                    fact that depends on several factors. Centres that have explicitly curated their recommendations are indicated by 
                    a tick in the 'Curated' column.</p>
                    <p>The life of a centre in a research infrastructure can be a dynamic affair, while the list below always 
                    only holds a snapshot of the state of the network at a certain (usually fairly random) date. We are not able to monitor
                    that in real time. If you see omissions or errors in the list below, please kindly 
                    <a title="open a new GitHub issue" href="https://github.com/clarin-eric/standards/issues/new?assignees=&amp;labels=centre+data%2C+templatic%2C+UserInput&amp;template=incorrect-missing-centre-recommendations.md&amp;title=Fix needed in the list of centres">let us know</a>.</p>
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
                    <table id ="centre-table">
                        <tr>
                            <th class="header" style="width:20%;"><a href="?sortBy=id#centre-table">ID</a></th>
                            <th class="header" style="width:30%;"><a href="?sortBy=name#centre-table">Name</a></th>
                            <th class="header" style="width:30%;">Research Infrastructure
                                <!--<a href="?sortBy=ri">Research Infrastructure</a>-->
                            </th>
                            <th class="header" style="width:10%;"><a href="?sortBy=depositing#centre-table">Depositing</a></th>
                            <th class="header" style="width:10%;"><a href="?sortBy=curated#centre-table">Curated</a></th>
                        </tr>
                        {cm:list-centre($sortBy, $status, $riCookie)}
                    </table>
                </div>
                <div class="footer">{app:footer()}</div>
            </div>
        </body>
    </html>