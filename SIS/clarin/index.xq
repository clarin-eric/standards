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
                    <p>The CLARIN Standards Information System lists language-technology-related standards 
                    that CLARIN centres are willing to accept and recognize and visualizes some of their 
                    interdependencies.</p>
                    <p>The system is in the process of development and extension. Until this notice is gone, 
                    the system should not be expected to provide exhaustive information. Please consult the 
                    CLARIN Standards Committee if you need up-to-date information.</p>
                    
                </div>
                <div><p>This website is managed by the CLARIN Standards Committee. Feedback on the <a href="schemas/spec.xsd">XML Schema</a> of <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">standard</a> 
                    descriptions may be sent to <a href="{app:link("views/contact.xq")}">the contact addresses</a>. CSC Members and CLARIN technical staff may also   
                    {if (session:get-attribute("user")) then "register" else <a href="{app:link("user/register.xq")}">register</a>} with this service.</p>
                </div>
                <!-- The tag cloud of standards and standard bodies -->
                <div style="margin-left:12%; margin-bottom:20px; width:450px;">
                    <div id="myCanvasContainer">
                        <canvas width="500" height="400" id="myCanvas"/>
                    </div>
                    <div id="tags" style="border:1px solid #DDDDDD; padding:8px;" >
                      {index:print-spec-links()}
                      {index:print-sb-links()}
                    </div>
                </div>                
            </div>            
            <div class="footer">{app:footer()}</div>        
        </div>
    </body>
</html>