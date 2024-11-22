xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace login = "http://clarin.ids-mannheim.de/standards/login" at "../modules/login.xql";

(: Define the logout page
   @author margaretha
:)

let $logout := login:logout()    

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
