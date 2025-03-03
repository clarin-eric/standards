xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace tm = "http://clarin.ids-mannheim.de/standards/topic-module" at "../modules/topic.xql";
import module namespace sbm = "http://clarin.ids-mannheim.de/standards/sb-module" at "../modules/sb.xql";
import module namespace search = "http://clarin.ids-mannheim.de/standards/search-spec" at "../modules/search-spec.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: Define search standard page
   @author margaretha
:)

let $query := request:get-parameter('query', "")
let $topic := request:get-parameter('topic', "")
let $sb := request:get-parameter('sb', "")
let $status := request:get-parameter('status', "")
let $submitted := request:get-parameter('submit', '')
let $CLARINapproved := request:get-parameter('CLARINapproved', '')
let $usedInCLARINCentre := request:get-parameter('usedInCLARINCentre', '')
let $results :=
if ($submitted)
then
    search:get-results($query, $topic, $sb, $status, $usedInCLARINCentre, $CLARINapproved)
else
    ()
return
    <html>
        <head>
            <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
            <title>Search Standards</title>
            <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
            <script type="text/javascript" src="{app:resource("session.js", "js")}"/>"/>
        </head>
        <body>
            <div id="all">
                <div class="logoheader"></div>
                {menu:view()}
                <div class="content">
                    <div class="navigation">
                        &gt; <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">Standards Watchtower</a>
                        &gt; <a href="{app:link("views/search-spec.xq")}">Search Standards</a>
                    </div>
                    <div><span class="title">Search for Standards</span></div>
                    <div>By default, given keyword(s) are matched to standard names. For an advanced search, you can specify the other optional fields.
                    </div>
                    <form method="get" action="{xs:anyURI("search-spec.xq")}" style="margin-bottom:40px;">
                        <table style="border:1px solid #AAAAAA; padding:20px;">
                            <tr>
                                <td width="120px"><b> Keywords: </b></td>
                                <td>
                                    <input name="query" type="text" class="inputText" value="{$query}" size="30" style="width:400px; margin-right:3px; margin-bottom:3px;"/>
                                </td>
                            </tr>
                            <tr>
                                <td><b>Topic:</b></td>
                                <td><select id="topic" name="topic" class="inputSelect" style="margin-bottom:3px;">
                                        <option value=""/>
                                        {tm:list-topic-options($topic)}
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td><b>Standardbody:</b></td>
                                <td><select id="sb" name="sb" class="inputSelect" style="margin-bottom:3px;">
                                        <option value=""/>
                                        {sbm:list-sbs-options($sb)}
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td><b>Status:</b></td>
                                <td><select id="status" name="status" class="inputSelect" style="margin-bottom:3px;">
                                        <option value=""/>
                                        {search:list-status($status)}
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td/>
                                <td>{
                                        if ($usedInCLARINCentre)
                                        then
                                            <input type="checkbox" name="usedInCLARINCentre" value="yes" checked="yes"/>
                                        else
                                            <input type="checkbox" name="usedInCLARINCentre" value="yes"/>
                                    }
                                    used in CLARIN centre(s)
                                </td>
                            </tr>
                            <!--<tr>
     				       <td/>
     				       <td>{if ($CLARINapproved)
     				            then <input type="checkbox" name="CLARINapproved" value="yes" checked="{$CLARINapproved}"/>
     				            else <input type="checkbox" name="CLARINapproved" value="yes"/> 
     				            }
     				            CLARIN approved
     				       </td>
     				   </tr> -->
                            <tr height="40px">
                                <td></td>
                                <td align="centre"><input name="submit" type="submit" value="Search" class="button"/></td>
                            </tr>
                        </table>
                    </form>
                    
                    {search:print-results($submitted, $results)}
                
                </div>
                <div class="footer">{app:footer()}</div>
            </div>
        </body>
    </html>