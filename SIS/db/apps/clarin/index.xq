xquery version "3.0";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "modules/app.xql";
import module namespace index="http://clarin.ids-mannheim.de/standards/index" at "modules/index.xql";

<html>
    <head>
        <title>CLARIN Standards Guidance</title>        
        <link rel="stylesheet" type="text/css" href="resources/css/style.css"/>
        <link rel="stylesheet" type="text/css" href="resources/css/tagclouds.css"/>
        <script type="text/javascript" src="resources/scripts/tagcanvas.min.js"/>
        <script type="text/javascript" src="resources/scripts/tagclouds.js"/>
    </head>
    <body onload="createTags()">
        <div id="all">
            <div class="logoheader"/>
            {menu:view()}
            <div class="content">
                <div class="navigation">&gt; <a href="{app:link("index.xq")}">Home</a></div>
                <div><span class="heading">CLARIN Standards Guidance</span></div>    
                <div>
                    <p>More and more research is conducted in a collaborative way involving people of different expertise.
                    A standard accomodating various needs and common objectives of such a research, is highly desired. To 
                    help choosing the best standard for your needs, this website provides information about standards of 
                    a various topics, especially those used in the area of linguistics and computerlinguistics. Moreover, 
                    you can compare different annotation schemas and metadata formats. 
                    </p>
                </div>
                <div>This website is developed within the collaborative CLARIN-D project. If you would like to support this work, 
                    you can send your feedback on the <a href="schemas/spec.xsd">XML Schema</a> of <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">standard</a> 
                    descriptions to <a href="{app:link("views/contact.xq")}">us</a>. Besides, you can submit your own standard description to us 
                    by {if (session:get-attribute("user")) then "registering" else <a href="{app:secure-link("user/register.xq")}">registering</a>}
                     to this website.
                </div>
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