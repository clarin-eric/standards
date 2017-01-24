xquery version "3.0";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace lsm="http://clarin.ids-mannheim.de/standards/list-spec" at "../modules/list-spec.xql";

let $sortBy := request:get-parameter('sortBy', '')
let $page := request:get-parameter('page', '') 
let $spec-group := lsm:group-specs($page)

return

<html>
	<head>
        <title>Standards</title>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
        <script type="text/javascript" src="{app:resource("d3.v2.js","js")}"/>
        <script type="text/javascript" src="{app:resource("forcegraph.js","js")}"/>        
    </head>
  <body onload="drawGraph('{lsm:get-spec-json($spec-group)}','650','550','-90');">
  <!--body-->  
  	<div id="all">
            <div class="logoheader"/>
			{menu:view()}
            <div class="content">
                <div class="navigation">&gt; <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">Standards</a></div>
                        
                <div class="title">Standards</div>
                
                <div>Information about the following standards are available ({ $lsm:spec-sum } in total). Click either on 
                the abbreviation of a specification, the name of its standard setting body, or one of its topic for further
                information. The standard names are shown by the tool tip when hovering over a standard abbreviation. Clicking on the column header will sort the list alphabetically according to that column header.
                </div>
        		
                <table cellspacing="4px">
                    <tr>
                        {lsm:header("name", $sortBy, $page)}
                        {lsm:header("topic", $sortBy, $page)}
                        {lsm:header("org", $sortBy, $page)}
                    </tr>
                    {lsm:list-specs($sortBy, $spec-group)}
                </table>
                <div style="text-align:center" >{lsm:page($sortBy, $page)}</div>                
                <div id="chart" class="version">
                    
                </div>
                <div class="version" style="width:380px; padding:0px">
                        <table>
                            <tr>
                                <td colspan="2" style="width:170px"><b>Legend:</b></td>
                                <td colspan="2" style="width:170px"></td>
                            </tr>
                            {lsm:get-legend($spec-group)}
                        </table>
                    </div>
            </div>
            <div class="footer">{app:footer()}</div>
		</div>			
	</body>
</html>