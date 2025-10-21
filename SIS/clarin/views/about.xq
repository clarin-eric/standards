xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: Define the contact page
   @author margaretha
:)

<html lang="en">
    <head>
        <title>About / F.A.Q.</title>
        <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
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
                <p>This service (more precisely, the original forms of its <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">"Standards Watchtower" section</a>) was created in 2012 
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
                homepages, as early as 2020 (and thereabouts). Some of these data had been supplied by members of the Standards 
                Committee connected with those centres, and, in selected cases that offered interesting testing grounds (e.g. 
                negative recommendations or inter-format relationships), the data was added by hand, on the basis of information 
                provided publicly by the centre (back then).</p>
                <p>Note that the information had to be interpreted by us, at least 
                with respect to the <a href="{app:link("views/list-domains.xq")}">functions of data</a> 
                and often with respect to the level of recommendation (recommended vs. acceptable vs. discouraged). That initial 
                state of information is only meant as 'seed' for further work by the centre itself. The need for that work had been 
                re-iterated in the committee presentations at the yearly CLARIN conferences, at NCF (National Coordinators' Forum) meetings, 
                and often directly in conversations with members of centres, to a moderate degree of success, until the Technical Centres 
                committee took the issue up as a cyclic task, in early 2024.</p></li>
                <li><h3>Why put work into the SIS if we can have our own page, structured and styled as we please?</h3>
                <p>The "as we please" bit would mean resigning from all the goodies that can be extracted out of data aggregation across CLARIN 
                (and, in the future, across comparable research infrastructures). The idea of the SIS is not only to make it possible to fulfil 
                the <a href="https://www.coretrustseal.org/">CTS</a> requirements in a relatively painless manner, but also to visualize the 
                aggregated data, and also to return the centre's 
                data back to it, thanks to the <a href="{app:link("views/api.xq")}">API point</a> that we make available.</p>
                <p>For example, for the IDS, you would use, e.g., 
                <tt>curl 'https://clarin.ids-mannheim.de/standards/rest/views/recommended-formats-with-search.xq?centre=IDS&amp;export=yes'</tt> -- 
                have a look at the API documentation to see what parameters are possible, etc.</p>

               <p>You can see an example way of querying the data with jQuery at 
               <a href="https://github.com/IDS-Mannheim/IDS-Mannheim.github.io">https://github.com/IDS-Mannheim/IDS-Mannheim.github.io</a>, and 
               the corresponding simple webpage is available for viewing at 
               <a href="https://ids-mannheim.github.io/standards/">https://ids-mannheim.github.io/standards/</a> (many browsers will allow you 
               to view the source by doing Ctrl+U). If you would like to contribute a CSS (or XSL) stylesheet to render the info in a nicer way, 
               please feel welcome to contact us and we will set up a directory for such contributions.</p>
                </li>
                <li><h3>Where can one learn more?</h3>
                <p>We will gladly deliver a zoom presentation to your centre -- please contact us about that.</p>
                <p>The Centres Committee has an internal checklist document for the purpose of tracking centres' progress -- if you're a 
                centre representative, please do contact your representative on the Centres' committee (or contact us).</p>
                <p>In the meantime, we have tried to make the system as frustration-free when it comes to updating or entering recommendations 
                by the individual centres, as possible. Please have a look at the <a href="https://github.com/clarin-eric/standards/wiki">documentation</a>
                and contact us (preferably via <a href="https://github.com/clarin-eric/standards/issues">GitHub issues</a>, so
                that you can see how we react and so that others can see that the issue is being worked on).</p>
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
                 
                 <div id="bibl">
                 <h2>Further reading</h2>
                 <p>The following publications focus on the Standards Information System at various stages of its development.</p>
                 <ul>
                 <li>Bański, Piotr and Eliza Margaretha Illig. 2024. <a href="https://ecp.ep.liu.se/index.php/clarin/article/view/1020">Standards 
                 Information System for CLARIN centres and beyond</a>. In: Lindén, Krister and Kontino, Thalassia and Niemi, Jyrki (eds) 
                 Selected papers from the CLARIN Annual Conference 2023. Series: Linköping Electronic Conference Proceedings 210. Linköping, 2024. 
                 DOI: <a href="https://doi.org/10.3384/ecp210004">https://doi.org/10.3384/ecp210004</a>.</li>
                 <li>Bański, Piotr and Hanna Hedeland. 2022. <a href="https://www.degruyter.com/document/doi/10.1515/9783110767377-012/html">Standards 
                 in CLARIN</a>. In: <i>CLARIN: The Infrastructure for Language Resources</i>. Darja Fišer and Andreas Witt (eds). De 
                 Gruyter (open access). DOI: <a href="https://doi.org/10.1515/9783110767377-012">https://doi.org/10.1515/9783110767377-012</a></li>
                 <li>Stührenberg, Maik, Antonina Werthmann, and Andreas Witt. 2012. 
                 <a href="https://ids-pub.bsz-bw.de/frontdoor/deliver/index/docId/4494/file/Stuehrenberg_Werthmann_Witt_Guidance_through_the_standards_jungle_2012.pdf">Guidance 
                 through the Standards Jungle for Linguistic Resources</a>. In Proceedings of the LREC 2012 Workshop on Collaborative Resource 
                 Development and Delivery, 9–13. URN: <a href="urn:nbn:de:bsz:mh39-44943">urn:nbn:de:bsz:mh39-44943</a></li>
                 </ul>
                 <p>The SIS offers some of its documentation through the <a href="https://github.com/clarin-eric/standards/wiki">GitHub wiki</a>.</p>
                 </div>
                 
                 <div id="tech">
                <h2>Technicalities</h2>
                 <p>The SIS is an open-source project hosted at <a href="https://github.com/clarin-eric/standards">GitHub</a>, built using mainly XQuery (1-3.1) and XML. 
                 It is running atop <a href="https://exist-db.org/exist/apps/homepage/index.html">eXist-db 6.3.x</a>.</p>
                 </div>
                 
                 </div>
            </div>            
            <div class="footer">{app:footer()}</div>
            </div>
    </body>
</html>