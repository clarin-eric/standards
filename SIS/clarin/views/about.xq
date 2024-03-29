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
        <title>About / F.A.Q.</title>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css","css")}"/>
        <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
    </head>
    <body>
        <div id="all">
            <div class="logoheader"/>
            {menu:view()}
            <div class="content">                
                <div class="navigation">&gt; <a href="{app:link("views/about.xq")}">About / F.A.Q.</a></div>                
                <div><span class="title">About SIS</span>
                
                
                <div id="about">
                <p>This service (more precisely, its <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">"Standards and Specifications" section</a>) was created in 2012 
                and has been maintained since then at <a href="https://www.ids-mannheim.de/">IDS Mannheim</a> 
                as part of the Institute's activity as a <a href="https://clarin.eu/">CLARIN</a> B-Centre. Around 2020, the system was refreshed and 
                extended with, among others, the section <a href="{app:link("views/recommended-formats-with-search.xq")}">"Format Recommendations"</a>. 
                Much of its history can be seen in the <a href="https://github.com/clarin-eric/standards">versioning system</a> hosted at GitHub.</p>
                <p>The SIS is listed as a knowledge base at Fairsharing: <a href="https://fairsharing.org/4705">https://fairsharing.org/4705</a></p>
                                </div>
                
                <div id="faq">
                <h2>Frequently Asked Questions</h2>
                <ol>
                <li><h3>The data about my centre do not seem entirely correct. Where did you take these recommendations from?</h3>
                <p>We bootstrapped the system with data coming from those centres that made that information available on their 
                homepages, as early as 2020 (and thereabouts). Note that the information had to be interpreted by us, at least 
                with respect to the <a href="{app:link("views/list-domains.xq")}">functions of data</a> 
                and often with respect to the level of recommendation (recommended vs. acceptable vs. discouraged). That initial 
                state of information is only meant as 'seed' for further work by the centre itself. The need for that work has been 
                re-iterated in the committee presentations at the yearly CLARIN conferences, at NCF (National Coordinators' Forum) meetings, 
                and often directly in conversations with 
                members of centres. We will gladly deliver a zoom presentation to your centre -- please contact us about that.</p>
                <p>In the meantime, we have tried to make the system as frustration-free when it comes to updating or entering recommendations 
                by the individual centres, as possible. Please have a look at the <a href="https://github.com/clarin-eric/standards/wiki">documentation</a>
                and contact us (preferably via <a href="https://github.com/clarin-eric/standards/issues">GitHub issues</a>, so
                that you can see how we react and so that others can see that the issue is being worked on).</p>
                </li>
                <li><h3>Why put work into the SIS if we can have our own page, structured and styled as we please?</h3>
                <p>The "as we please" bit would mean resigning from all the goodies that can be extracted out of data aggregation across CLARIN 
                (and, in the future, across comparable research infrastructures). The idea of the SIS is not only to make it possible to fulfil 
                the <a href="https://www.coretrustseal.org/">CTS</a> requirements in a relatively painless manner, but also to visualize the 
                aggregated data, and also to return the centre's 
                data back to it, thanks to the <a href="{app:link("views/api.xq")}">API point</a> that we make available. "Soon" (hopefully 
                after the summer of 2023 at the latest), we will provide examples of how a centre can make use of its data that have been 
                input into the SIS in order to display them on the centre's own pages.</p>
                </li>
                </ol>
                </div>
                
                <div id="contact">
                <h2>Contact</h2>
                <p>If you have any question or feedback about the content of this website, please consider using <a href="https://github.com/clarin-eric/standards/issues">GitHub issues</a>, 
                so that you can see how the matter is processed and what decisions are made (and often why). Link to pre-filled 
                templates of GitHub issues are also placed at various crucial spots in the SIS.</p>
                <p>If issues do not suffice for some reason, contact us directly at the addresses below, but please be aware 
                that that often extends the path (because then, most often, we need to re-post your issue ourselves, and that might take a while, and until then, 
                the process is non-transparent), and consequently the time to handle your feedback.</p>
                
                <p><b>Eliza Margaretha (main developer) </b><br />
                    <img src="{app:resource("margaretha.png","img")}"/><br />
                   <b>Piotr Banski (conceptual work and contact to the CLARIN <a href="https://www.clarin.eu/content/standards">Standards and Interoperability Committee</a>)</b><br />
                    <img src="{app:resource("banski.png","img")}"/> <br />
                    
                    Institut für Deutsche Sprache <br />
                    R5, 6-13 <br />
                    68-161 Mannheim <br />
                    Germany
                </p>
                 </div>
                 
                 
                 <div id="tech">
                <h2>Technicalities</h2>
                 <p>The SIS is an open-source project hosted at <a href="https://github.com/clarin-eric/standards">GitHub</a>, built using mainly XQuery (1-3.1) and XML. 
                 It is running atop <a href="https://exist-db.org/exist/apps/homepage/index.html">eXist-db 6.2.0</a>.</p>
                 </div>
                 
                 </div>
            </div>            
            <div class="footer">{app:footer()}</div>
            </div>
    </body>
</html>