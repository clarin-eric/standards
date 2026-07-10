xquery version "3.1";

module namespace sis = 'sis';

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace lsm = "http://clarin.ids-mannheim.de/standards/list-spec" at "../modules/list-spec.xql";
import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";

import module namespace index="http://clarin.ids-mannheim.de/standards/index" at "../modules/index.xql";

(: Define the list of spec page
   @author margaretha
:)

declare
  %rest:path('/clarin/views/intro-specs.xq')
  %output:method('html')
  %output:media-type("text/html")
  %output:indent("yes")
  %output:html-version("5")
function sis:print() as element(html) {
  
      <html lang="en">
          <head>
              <title>Introduction</title>
              <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
              <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
              
              <script>
                    document.addEventListener('DOMContentLoaded', function() {{
                    window.onload=init();
                  }});
                  
                  function init(){{
                      checkActiveRI();
                      createTags();
                  }}
              </script>
              <link rel="stylesheet" type="text/css" href="{app:resource("tagclouds.css", "css")}"/>
              <script type="text/javascript" src="{app:resource("tagcanvas.min.js", "js")}"/>
              <script type="text/javascript" src="{app:resource("tagclouds.js","js")}"/>
              <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
          </head>
           <body>
                <!--body-->
                <div id="all">
                    <a class="logoheader" href="https://www.clarin.eu/"/>
                    {menu:view("Introduction")}
                  <div class="content">
                      <div class="navigation">
                      &gt; <a href="{app:link("views/watchtower.xq")}">Standards Watchtower</a>                      
                      &gt; <a href="{app:link("views/intro-specs.xq")}">Introduction</a>
                          
                      </div>
                      
                      <div class="title">Introduction: standards and specifications</div>
                      
                      <div>                    
                                            
                        <!-- <h2 id="introduction">Introduction: standards and specifications</h2>
                         -->
                        <p>ISO defines a <a href="https://www.iso.org/obp/ui#home">standard</a> as “a document that provides requirements, 
                        specifications, guidelines or characteristics that can be used consistently to ensure that materials, products, 
                        processes and services are fit for their purpose.” Commonly, a standard developed within a standardization body
                        must meet some strict requirements and rules defined by a panel of experts. After going through a public review 
                        process, the standardization organization members (e.g. representatives from governmental, industry or academic 
                        organisations) must agree that the standard can be published. Although the standardization process is time-consuming, 
                        it ensures a transparent and fair development of standards with respect to considerations of multiple perspectives 
                        and needs of all members of a standardization organization. The official standards that are developed within one 
                        accredited body, such as ISO, DIN, IEEE, CEN/ISSS or NISO, are generally defined as <i>de jure</i> standards.</p>
                        <p>On the other hand, a (technical) specification is “document that prescribes technical requirements to
                        be fulfilled by a product, process or service” (see <a href="https://www.iso.org/iso-guides.html">ISO/IEC Guide 2</a>). 
                        Any private individual, company or organization may develop a specification, which is typically limited to a specific 
                        application and defines the tasks and objectives of that application. When a specification is often used and acknowledged by 
                        the users more than any other existing specification, it is referred to as a <i>de facto</i> standard.
                        Many specifications, such as PDF, CMDI, HTML, were developed outside a standardization body, but by the virtue of acceptance 
                        and broad dissemination, they got later adopted by a recognized standardization body, such as ISO.</p>
                        </div>
                        <!-- The tag cloud of standards and standard bodies -->
                        <div style="margin-left:10%; margin-bottom:20px;">
                            <div id="myCanvasContainer">
                                <canvas width="600" height="500" id="myCanvas"/>
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
};