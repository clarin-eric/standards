xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace stm = "http://clarin.ids-mannheim.de/standards/statistics-module" at "../modules/statistics.xql";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace domain = "http://clarin.ids-mannheim.de/standards/domain" at "../model/domain.xqm";
import module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module" at "../modules/centre.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: 
    @author margaretha
:)

let $ris as xs:string* := cm:get-current-research-infrastructures() (: use the live list rather than the schema :)

return 
<html lang="en">
    <head>
        <title>Centre Statistics</title>
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
                    &gt; <a href="{app:link("views/list-statistics-formats.xq")}">Centre Statistics</a>
                </div>
                <div class="title">Centre Statistics</div>

                    <div><p>These statistics provide numbers concerning the centres stored in the SIS. The "RI" column 
                    lists research infrastructures (note that a single centre may represent more than one RI). 
                    Depositing centres are those that allow for data deposition. They may be a proper subset of all 
                    centres for the given RI, given the usual fluctuations in the status. The last column counts those 
                    centres that actively maintain the information stored in the SIS, and that have designated a curator
                    for that information. See the verbose <a href="{app:link("views/list-centres.xq")}">list of centres</a> 
                    for more information. </p>
                    <p>As far as RIs (research infrastructures) other than CLARIN are concerned, as of 2025, the tables 
                    below only list those DARIAH and Text+ repositories which are also CLARIN centres. We are open to the 
                    idea of extending the current coverage.</p>
                    </div>
                    <table style="width:600px">
                        <tr>
                            <th style="width:100px">RI</th>
                            <th style="text-align:center;">Number of centres</th>
                            <th style="text-align:center;">Depositing centres</th>
                            <th style="text-align:center;">Centres with recommendations</th>
                            <th style="text-align:center;">Centres with curated recommendations</th>
                        </tr>
                       <!-- {stm:list-all-centre-statistics()} without ri-->
                        {stm:list-centre-statistics()}
                    </table>
                    <div>
                    <h2 id="statsByStatus">Statistics by centre status</h2>
                    <p>The tables below look at the individual research infrastructures one by one and split the statistics according to the status of the centre.</p>
                    
                    {
                    for $ri in $ris 
                        return 
                     <div style="margin-top:30px;">
                            <h3 id="{concat('stats',$ri)}">{$ri ! cm:visualise-ri-name(.)}</h3>
                     <table style="width:600px">
                        <tr>
                            <th style="width:100px">Status</th>
                            <th style="text-align:center;">Number of centres</th>
                            <th style="text-align:center;">Depositing centres</th>
                            <th style="text-align:center;">Centres with recommendations</th>
                            <th style="text-align:center;">Centres with curated recommendations</th>
                        </tr>
                        {stm:list-status-statistics($ri)}
                    </table>
                    </div>
                    }
                    
                    </div>
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>
