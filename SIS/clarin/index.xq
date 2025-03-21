xquery version "3.0";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "modules/app.xql";
import module namespace index="http://clarin.ids-mannheim.de/standards/index" at "modules/index.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(:  This is the homepage of the website.
    @author margaretha
:)


<html lang="en">
    <head>
        <title>CLARIN Standards Information System</title>
        <link rel="icon" type="image/x-icon" href="resources/images/medal-sis.png"/>        
        <link rel="stylesheet" type="text/css" href="resources/css/style.css"/>    
        <link rel="stylesheet" type="text/css" href="resources/css/tagclouds.css"/>
        <script>
            document.addEventListener('DOMContentLoaded', function() {{
            window.onload=init();
          }});
          
          function init(){{
              checkActiveRI();
              createTags();
          }}
        </script>
        <script type="text/javascript" src="resources/scripts/tagcanvas.min.js"/>
        <script type="text/javascript" src="resources/scripts/tagclouds.js"/>
        <script type="text/javascript" src="resources/scripts/session.js"/>
    </head>
    <body>
        <div id="all">
            <div class="logoheader"/>
            <!-- Menu -->
            {menu:view()}
            <div class="content">
                <div class="navigation">&gt; <a href="{app:link("index.xq")}">Home</a></div>
                <div class="title">CLARIN Standards Information System</div>
                <div>
                    
                    <p>The primary role of the CLARIN Standards Information System is, currently, to aggregate and visualize 
                    the list of recommendations for data deposition formats, specified by CLARIN centres that offer 
                    <a href="https://www.clarin.eu/content/depositing-services">deposition services</a>
                    (mostly the so-called <a href="https://www.clarin.eu/content/clarin-centres">B-centres</a>). 
                    That list is available in the 
                    "<a href="{app:link("views/recommended-formats-with-search.xq")}"><b>Format Recommendations</b></a>" 
                    section, and its various logical subcomponents can be accessed from the menu on the left.</p>
                    <p>Note also the tabs along the upper edge of the page -- the SIS (partially) serves the needs of 
                    two sister research infrastructures, aggregating and visualising the relevant information.</p>
                    <p>The keyword cloud below provides an alternative way to access the format and recommendation 
                    information.</p> 
                </div>
                <div style="margin-left:10%; margin-bottom:15px;">
                    <div id="myCanvasContainer">
                        <canvas width="600" height="500" id="myCanvas"/>
                    </div>
                    <div id="tags" style="border:1px solid #DDDDDD; padding:8px;" >
                      <!--{index:print-spec-links()}
                      {index:print-sb-links()}
                      -->
                      {index:print-format-keywords()}
                    </div>
                </div>                

                <div>
                <p>The original and, at this time, not actively developed function of the SIS is to collect information on the 
                human language technology standards in use by the CLARIN community. Visit the 
                "<a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}"><b>Standards Watchtower</b></a>" section in order to access 
                that functionality. That section is going to expand in the course of the year 2025, so visit us often...</p>
                <p style="text-align:center">* * * * *</p>
                </div>

                <div>
                <p>This website is managed by the Digital Linguistics department of IDS Mannheim for the 
                <a title="see the list of members" href="https://www.clarin.eu/governance/standards-committee">CLARIN Standards and Interoperability Committee</a>. 
                Feel welcome to contact us via "issues" at <a title="access the SIC issues centre" href="https://github.com/clarin-eric/standards/issues">our GitHub repository</a> with 
                suggestions or problem reports.</p>
                    <p>See the wiki pages <a title="access info on how to contribute" href="https://github.com/clarin-eric/standards/wiki/How-to-contribute-to-the-SIS">"How to contribute to the SIS"</a> 
                    and <a  title="access info on how to react to incomplete information" href="https://github.com/clarin-eric/standards/wiki/Updating-format-recommendations">"Updating format recommendations"</a> 
                    for hints on how you can influence the SIS. All feedback is very welcome.</p>
                    <p>Please consult the <a title="SIC visiting card" href="https://www.clarin.eu/content/standards">"visiting card" of the CLARIN Standards and Interoperability Committee</a> 
                    for more information on activities that the SIC is involved in.</p>
                </div>
                
            </div>            
            <div class="footer">{app:footer()}</div>        
        </div>
    </body>
</html>