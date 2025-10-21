xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace asm ="http://clarin.ids-mannheim.de/standards/add-spec-module" at "../modules/add-spec.xql";
import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

let $id := request:get-parameter('id', '')
let $spec := asm:get-spec($id)
let $spec-name := $spec/titleStmt/title/text()

return
<html lang="en">
    <head>
       <title>Registering Standard Parts</title>   
       <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
        <script type="text/javascript" src="{app:resource("edit.js","js")}"/>
    </head>   
    <body>
        <div id="all">
        <div class="logoheader"/>		
             {menu:view()}
        <div class="content">
             <div class="navigation">
                &gt; <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">Standards</a>               
                &gt; <a href="{app:link("views/register-spec.xq")}">Register</a>
                &gt; Adding Parts
                &gt; Adding Versions
                &gt; Confirmation
             </div>                    
             
             <div class="title">Registering Standard</div>
             <div> <p>You have completed the standard registration steps. Your standard will be reviewed by an administrator. Once it has 
                been approved, it will be listed in the 
                <a href="{app:link("views/list-spec.xq?sortBy=name&amp;page=1")}">Standards</a> page. Your registered 
                standard may be further elaborated by the administrator.</p>
                <p style="font-weight:bold">Thank you for registering {$spec-name}!</p>
             </div>             
        </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html> 