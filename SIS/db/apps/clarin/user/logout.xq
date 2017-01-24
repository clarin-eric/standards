xquery version "3.0";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat"; 

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace login = "http://clarin.ids-mannheim.de/standards/login" at "../modules/login.xql";

let $logout := 
    if (session:get-attribute("user"))
    then login:destroy-session()
    else app:secure-link("user/login.xq")

return 
    <html>
       <head>
    		<title>Logout</title>
    		<link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>			
    	</head>
    	<body>
    		<div id="all">
    			<div class="logoheader"/>	
    			{menu:view()}
    			<div class="content">
    			    <div class="navigation">&gt; Logout</div>			    	
                    <div><span class="heading">You have been logged out.</span></div>
          	     </div>
                <div class="footer">{app:footer()}</div>               
    		</div>
    	</body>
   </html>
