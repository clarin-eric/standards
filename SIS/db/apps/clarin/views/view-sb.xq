xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace sbm = "http://clarin.ids-mannheim.de/standards/sb-module" at "../modules/sb.xql";
import module namespace vsb="http://clarin.ids-mannheim.de/standards/view-sb" at "../modules/view-sb.xql";


let $id := request:get-parameter('id', '')
let $sb := sbm:get-sb($id)
let $sb-title := $sb/titleStmt/title/text()
let $abbr := $sb/titleStmt/abbr/text()
   
let $sb-abbr :=
    if (fn:contains($abbr,"/"))
    then vsb:get-sb-links($id,$abbr)
    else ($abbr)

let $standards := sbm:get-specs-by-sb($id)
let $color := sbm:get-color()
return 

<html>
	<head>
		<title>Standard Setting Body: {$sb-title}</title>
		<link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
		<script type="text/javascript" src="{app:resource("d3.v2.js","js")}"/>
        <script type="text/javascript" src="{app:resource("forcegraph.js","js")}"/>
	</head>
	
	<body onload="drawGraph('{sbm:get-sb-json($id)}','500','300','-100');">
		<div id="all">
			<div class="logoheader"/>
			{menu:view()}
            <div class="content">
                <div class="navigation">
                    &gt; <a href="{app:link("views/list-sbs.xq")}">Standard Bodies</a>
                    &gt; <a href="{app:link(concat("views/view-sb.xq?id=",$sb/@id))}">{$sb-title}</a>
                </div>
    			<div class="title">{$sb-title}
    			 {if (not($sb-title = $sb-abbr)) then( " (",$sb-abbr,")") else ()}
    			</div>
    			{for $respStmt in $sb/titleStmt/respStmt 
    			 return 
    			     <div>
    			         <span class="heading">{$respStmt/resp/text()}: </span> {$respStmt/name/text()}
    			      </div>    			 
    			}    			
    			<div>{sbm:print-description($sb)}
    			</div>    			    			
    			
    			{if ($standards) 
    			 then ( <div class="heading">Specifications standardized by this body:</div>,
              			<ol>{$standards}</ol>)
    			 else ()}    			 
    			 <br/>
    			 {if($sb/relation)
    			  then (
    		      <div id="chart" class="version">
    		          <div class="version" style="width:140px; float:right; padding:0px">
                            <table>
                               <tr>
                                   <td colspan="2"><b>Legend:</b></td>                    
                               </tr>
                               <tr>
                                   <td><hr style="border:0; color:{$color}; background-color:{$color}; height:2px; width:20px" /></td>
                                   <td>hasPart</td>
                               </tr>
                             </table>
                      </div>
                    </div>)
    		      else()
    			 }
    		</div>    		
			<div class="footer">{app:footer()}</div>
		</div>
	</body>
</html>