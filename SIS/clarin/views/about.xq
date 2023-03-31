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
                <div class="navigation">&gt; <a href="{app:link("views/about.xq")}">About / F.A.Q.</a></div>                
                <div><span class="title">About SIS</span></div>
                
                
                <div id="about">
                </div>
                
                <div id="faq">
                <h2>Frequently Asked Questions</h2>
                <ol>
                <li><h3>The data about my centre do not seem entirely correct. Where did you take these recommendations from?</h3>
                <p>We bootstrapped the system with data coming from those centres that made that information available on their 
                homepages. Note that the information had to be interpreted by us, at least with respect to the functions of data 
                and often with respect to the level of recommendation (recommended vs. acceptable vs. discouraged). That initial 
                state of information is only meant as 'seed' for further work by the centre.</p>
                </li>
                </ol>
                </div>

                
                <div id="contact">
                <h2>Contact</h2>
                <p>If you have any question or feedback about the content of this website
                or the <a href="{app:link("schemas/spec.xsd")}"> XML Schema</a> of the 
                <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">standards</a>, 
                please contact:</p>
                
                <p><b>Eliza Margaretha (main developer) </b><br />
                    <img src="{app:resource("margaretha.png","img")}"/><br />
                   <b>Piotr Banski (contact to CLARIN Standards Committee) </b><br />
                    <img src="{app:resource("banski.png","img")}"/> <br />
                    
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