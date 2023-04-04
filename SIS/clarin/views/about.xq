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
                <p>This service has been created and is maintained at IDS Mannheim as part of the Institute's activity </p>
                </div>
                
                <div id="faq">
                <h2>Frequently Asked Questions</h2>
                <ol>
                <li><h3>The data about my centre do not seem entirely correct. Where did you take these recommendations from?</h3>
                <p>We bootstrapped the system with data coming from those centres that made that information available on their 
                homepages, as early as 2020 (and thereabouts). Note that the information had to be interpreted by us, at least 
                with respect to the functions of data used by the SIS 
                and often with respect to the level of recommendation (recommended vs. acceptable vs. discouraged). That initial 
                state of information is only meant as 'seed' for further work by the centre. The need for that work has been 
                re-iterated in the committee presentations at CACs, at NCF meetings, and often directly in conversations with 
                members of centres.</p>
                <p>In the meantime, we have tried to make the system as frustration-free when it comes to updating or entering recommendations 
                by the individual centres, as possible. Please have a look at the documentation and contact us (best via GitHub issues, so 
                that you can see how we respond).</p>
                </li>
                </ol>
                </div>

                
                <div id="contact">
                <h2>Contact</h2>
                <p>If you have any question or feedback about the content of this website, please consider using GitHub issues, 
                so that you can see how the matter is processed and what decisions are made (and often why). Link to pre-filled 
                templates of GitHub issues are also placed at various crucial spots in the SIS.</p>
                <p>If issues don't suffice for some reason, contact us directly at the addresses below, but please be aware 
                that that often extends the path (because then, 
                most often, we need to post your issue, and that might take a while, and until then, the process is non-transparent), and consequently the time to handle your feedback.
                
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