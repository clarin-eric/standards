xquery version "3.0";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "modules/app.xql";
import module namespace index="http://clarin.ids-mannheim.de/standards/index" at "modules/index.xql";

(:  This is the homepage of the website.
    @author margaretha
    @date Dec 2013
:)


<html>
    <head>
        <title>CLARIN Standards Information System</title>        
        <link rel="stylesheet" type="text/css" href="resources/css/style.css"/>    
        <link rel="stylesheet" type="text/css" href="resources/css/tagclouds.css"/>
        <script type="text/javascript" src="resources/scripts/tagcanvas.min.js"/>
        <script type="text/javascript" src="resources/scripts/tagclouds.js"/>
        <script type="text/javascript" src="resources/scripts/session.js"/>
    </head>
    <body onload="createTags()">
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
                    "<a href="{app:link("views/recommended-formats-with-search.xq")}">Format Recommendations</a>" 
                    section, and its various logical subcomponents can be accessed from the menu on the left.</p>
                    <p>The keyword cloud below provides an alternative way to access the format and recommendation 
                    information. It is still in the process of being fine-tuned.</p> 
                </div>
                <div style="margin-left:10%; margin-bottom:20px;">
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
                LRT standards in use by the CLARIN community. Visit the 
                "<a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">Standards and Specifications</a>" section in order to access 
                that functionality.</p>
                <p style="text-align:center">* * * * *</p>
                </div>

                <div>
                <p>This website is managed by the <a href="https://www.clarin.eu/governance/standards-committee">CLARIN Standards Committee</a>. 
                Feel welcome to contact us via "issues" at <a href="https://github.com/clarin-eric/standards/issues">our GitHub repository</a> with 
                suggestions or problem reports.</p>
                    <p>See the wiki pages <a href="https://github.com/clarin-eric/standards/wiki/How-to-contribute-to-the-SIS">"How to contribute to the SIS"</a> 
                    and <a href="https://github.com/clarin-eric/standards/wiki/Updating-format-recommendations">"Updating format recommendations"</a> 
                    for hints on how you can influence the SIS.</p>
                    <p>Please consult the <a href="https://www.clarin.eu/content/standards">"visiting card" of the CLARIN Standards Committee</a> for more information on CSC activities.</p>
                   
                   <!-- <p>CSC Members and CLARIN technical staff may 
                    {if (session:get-attribute("user")) then "register" else <a href="{app:link("user/register.xq")}">register</a>} with this service.</p>-->
                </div>
                
            </div>            
            <div class="footer">{app:footer()}</div>        
        </div>
    </body>
</html>