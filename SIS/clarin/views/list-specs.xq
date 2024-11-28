xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace lsm = "http://clarin.ids-mannheim.de/standards/list-spec" at "../modules/list-spec.xql";
import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";

import module namespace index="http://clarin.ids-mannheim.de/standards/index" at "../modules/index.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: Define the list of spec page
   @author margaretha
:)

let $sortBy := request:get-parameter('sortBy', '')
let $page := request:get-parameter('page', '')
let $letter := request:get-parameter('letter', '')
let $spec-group := lsm:group-specs($page, $sortBy, $letter)
let $spec-relations := $spec-group//relation

return
   (: if ($spec-relations)
    then lsm:get-spec-json($spec-group, $spec-relations)
    else :)
    <html lang="en">
        <head>
            <title>Standards Watchtower</title>
            <link rel="icon" type="image/x-icon" href="../resources/images/SIS-favicon.svg"/>
            <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
            
            <script>
                  document.addEventListener('DOMContentLoaded', function() {{
                  window.onload=init();
                }});
                
                function init(){{
                    checkActiveRI();
                    createTags();
                    drawGraph('{lsm:get-spec-json($spec-group, $spec-relations)}','650','550','-90');
                }}
            </script>
            <script type="text/javascript" src="{app:resource("d3.v2.js", "js")}"/>
            <script type="text/javascript" src="{app:resource("forcegraph.js", "js")}"/>
            
            <link rel="stylesheet" type="text/css" href="{app:resource("tagclouds.css", "css")}"/>
            <script type="text/javascript" src="{app:resource("tagcanvas.min.js", "js")}"/>
            <script type="text/javascript" src="{app:resource("tagclouds.js","js")}"/>
            
            <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
        </head>
        <body>
            <!--body-->
            <div id="all">
                <div class="logoheader"/>
                {menu:view()}
                <div class="content">
                    <div class="navigation">&gt; <a href="{app:link("views/list-specs.xq?sortBy=name&amp;page=1")}">Standards Watchtower</a>
                        {
                            if ($letter) then
                                (" > ",
                                <a href="{app:link(concat("views/list-specs.xq?sortBy=name&amp;page=1&amp;letter=", $letter))}">
                                    {$letter}</a>)
                            else
                                ()
                        }
                    </div>
                    
                    <div class="title">Standards Watchtower</div>
                    
                    <div>
                    
                    <p></p>
                    <p>Note: information provided in this part of the Standards Information System may be outdated. 
                    This means that the relationships between standards and specifications listed here are still valid, 
                    but some new versions (and consequently new relationships) may still be missing. Since this is an 
                    open system, you are cordially invited to help extend it, either by posting a ticket listing the 
                    missing information, or by forking/cloning the source and submitting your additions via a pull request.</p>
                   
                    <h2 id="introduction">Introduction</h2>
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
                    
                    <div id="list">
                    <h2>Content</h2>
                        <p>The table below lists the {$lsm:spec-sum} standards and specifications described in this website. You can get more 
                        information about a standard or a specification by clicking on the abbreviations. When hovering over an abbreviation, 
                        the standard/specification name will be shown on a tooltip. The topic column shows which area(s) a standard belongs 
                        to, and the resonsibility column shows the person, organization or standardization body that has developed or 
                        currently maintains the standard/specification. The CLARIN Centre(s) column shows which clarin centres using a 
                        particular standard/specification. </p>
                        <p>To sort the table below by topic, responsibility or CLARIN centre, please click on the corresponding column header. 
                        You can also filter the standards by the first letter of their abbreviation or name, by clicking on a letter below.</p>
                        <p>Please note that the information concerning centre recommendations for particular standards should be considered 
                        outdated and will change with the upcoming revisions of the Standards Information System. Please refer to the 
                        "<a href="{app:link("views/recommended-formats-with-search.xq")}">Format Recommendations</a>" page for up-to-date 
                        information on centre recommendations concerning standard / specification serializations (file formats) that may be 
                        used to exchange data.</p>
                    </div>
                    
                    <div id="spec-table">{lsm:letter-filter()}</div>
                    
                    {
                        if (count($spec-group) > 0)
                        then
                            (
                            <table cellspacing="4px" style="width:97%">
                                <tr>
                                    {lsm:header("name", $sortBy, $page, $letter)}
                                    {lsm:header("topic", $sortBy, $page, $letter)}
                                    {lsm:header("org", $sortBy, $page, $letter)}
                                    {lsm:header("clarin-centres", $sortBy, $page, $letter)}
                                    <!--{lsm:header("clarin-approved", $sortBy, $page)}-->
                                </tr>
                                {lsm:list-specs($spec-group, $sortBy, $letter)}
                            </table>,
                            <div style="text-align:centre">
                                {
                                    if ($letter) then
                                        <br/>
                                    else
                                        lsm:page($sortBy, $page)
                                }
                            </div>,
                            <div id="chart" class="version">
                            </div>,
                            <div class="version" style="width:380px; padding:0px">
                                <table>
                                    <tr>
                                        <td colspan="2" style="width:170px"><b>Legend:</b></td>
                                        <td colspan="2" style="width:170px"></td>
                                    </tr>
                                    {lsm:get-legend($spec-relations)}
                                </table>
                            </div>
                            )
                        else
                            <div>No standards are found.</div>
                    }
                </div>
                <div class="footer">{app:footer()}</div>
            </div>
        </body>
    </html>