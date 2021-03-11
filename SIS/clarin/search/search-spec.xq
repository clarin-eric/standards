xquery version "3.0";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace tm ="http://clarin.ids-mannheim.de/standards/topic-module" at "../modules/topic.xql";
import module namespace sbm="http://clarin.ids-mannheim.de/standards/sb-module" at "../modules/sb.xql";
import module namespace search ="http://clarin.ids-mannheim.de/standards/search-spec" at "../modules/search-spec.xql";

(: Define search standard page
   @author margaretha
:)

let $query := request:get-parameter('query', "")
let $topic := request:get-parameter('topic', "")
let $sb := request:get-parameter('sb', "")
let $status := request:get-parameter('status', "")
let $submitted := request:get-parameter('submit', '')
let $CLARINapproved := request:get-parameter('CLARINapproved', '')
let $usedInCLARINCenter := request:get-parameter('usedInCLARINCenter', '')
let $results := 
    if ($submitted) 
    then search:get-results($query, $topic, $sb, $status, $usedInCLARINCenter, $CLARINapproved)    
    else()
return 
<html>
	<head>
		<title>Search Standards</title>
		<link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
	</head>
	<body>
		<div id="all">
			<div class="logoheader"></div>
			{menu:view()}
			<div class="content">
                <div class="navigation">
                    &gt; <a href="{app:link("search/search-spec.xq")}">Search Standards</a>
                </div>
                <div><span class="heading">Search for Standards</span></div>
     			<div>By default, given keyword(s) are matched to standard names. For an advanced search, you can specify the other optional fields.
     		    </div>
     			<form method="get" action="{xs:anyURI("search-spec.xq")}" style="margin-bottom:40px;">
     				<table style="border:1px solid #AAAAAA; padding:20px;"> 
     				   <tr>
     				       <td width="120px"><b> Keywords: </b></td>
     				       <td>
     				            <input name="query" type="text" class="inputText" value="{$query}" size="30" style="width:400px; margin-right:3px; margin-bottom:3px;" />
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
     				       <td>{if ($usedInCLARINCenter)
     				            then <input type="checkbox" name="usedInCLARINCenter" value="yes" checked="yes"/> 
     				            else <input type="checkbox" name="usedInCLARINCenter" value="yes"/>
     				           }
     				           used in CLARIN center(s)
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
     				       <td align="center"><input name="submit" type="submit" value="Search" class="button" /></td>
     				   </tr>     				        				   
     				</table>		
     			</form>
     			     			
     			{ search:print-results($submitted, $results) }
     			
            </div>
			<div class="footer">{app:footer()}</div>
		</div>
	</body>
</html>