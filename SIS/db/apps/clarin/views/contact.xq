xquery version "3.0";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";

(: Define the contact page
   @author margaretha
:)

<html>
    <head>
        <title>Contact</title>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
    </head>
    <body>
        <div id="all">
            <div class="logoheader"/>
            {menu:view()}
            <div class="content">                
                <div class="navigation">&gt; <a href="{app:link("views/contact.xq")}">Contact</a></div>                
                <div><span class="heading">Contact</span></div>
                
                <div>If you have any question or feedback about the content of this website
                or the <a href="{app:link("schemas/spec.xsd")}"> XML Schema</a> of the 
                <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">standards</a>, 
                please contact:
                
                <p><b> Antonina Werthmann </b><br />
                    <img src="{app:resource("werthmann.png","img")}"/> <br />
                    <b>Eliza Margaretha </b><br />
                    <img src="{app:resource("margaretha.png","img")}"/><br />
                   <b>Dr. Maik Stührenberg </b><br />
                    <img src="{app:resource("stuehrenberg-ids.png","img")}"/> <br />
                    
                    Institut für Deutsche Sprache <br />
                    R5, 6-13 <br />
                    68161 Mannheim <br />
                    Germany
                </p>
                 </div>
            </div>            
            <div class="footer">{app:footer()}</div>        
        </div>
    </body>
</html>