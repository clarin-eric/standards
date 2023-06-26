xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace tm="http://clarin.ids-mannheim.de/standards/topic-module" at "../modules/topic.xql";

(:  Define the topic page
    @author margaretha
    @date Dec 2013
:)

let $id := request:get-parameter('id', '')
let $topic := tm:get-topic($id)
let $topic-name := $topic/titleStmt/title/text()

return 

<html>
	<head>
		<title>{$topic-name}</title>
		<link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
		<script type="text/javascript" src="{app:resource("session.js", "js")}"/>
	</head>
	<body>
		<div id="all">
			<div class="logoheader"/>	
			{menu:view()}
			{if ($id and $topic) then
     			<div class="content">	
                     <div class="navigation">&gt; <a href="list-topics.xq">Topics</a>                     
                          &gt; <a href="{app:link(concat("views/view-topic.xq?id=",$topic/@id))}">{$topic-name}</a>
                     </div>                
              		<div class="title">{$topic-name}</div>         		
              		<div>{$topic/info[@type="description"]/*}</div>         		
              		<div class="heading">Standards dealing with this topic:</div>
                   	<ol>{tm:get-specs-by-topic($id,'')}</ol>
              	 </div>
         	 else
         	   <div class="content">	
                    <div class="navigation">&gt; <a href="list-topics.xq">Topics</a> </div>
                    <div><span class="heading">The requested topic information is not found.</span></div>
               </div>
         	 
         	}
            <div class="footer">{app:footer()}</div>               
		</div>
	</body>
</html>