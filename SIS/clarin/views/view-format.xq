xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";

import module namespace vfm = "http://clarin.ids-mannheim.de/standards/view-format" at "../modules/view-format.xql";
import module namespace vsm = "http://clarin.ids-mannheim.de/standards/view-spec" at "../modules/view-spec.xql";

import module namespace domain = "http://clarin.ids-mannheim.de/standards/domain" at "../model/domain.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

let $id := request:get-parameter('id', '')
let $centre := request:get-parameter('centre', '')
let $domain := request:get-parameter('domain', '')
let $recommendationType := request:get-parameter('type', '')
let $sortBy := request:get-parameter('sortBy', 'centre')

let $ri := app:get-ri()
let $language := app:determine-language($ri)

let $format := vfm:get-format($id)
let $format-name := $format/titleStmt/title/text()
let $format-abbr := $format/titleStmt/abbr/text()

let $format-domains := vfm:get-recommended-domains-by-format($id)

let $is-umbrella as xs:boolean := fn:boolean($format/info/@umbrella)

return
    
    if (not($id) or not($format)) then
        <html lang="en">
            <head>
                <title>Not Found</title>
                <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
                <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
                <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
            </head>
            <body>
                <div id="all">
                    <div class="logoheader"/>
                    {menu:view()}
                    <div class="content">
                        <div class="navigation"> &gt;
                            <a href="{app:link("views/list-formats.xq")}">Data Deposition Formats</a>
                        </div>
                        <div><span class="heading">The requested format information is not found.</span></div>
                    </div>
                    <div class="footer">{app:footer()}</div>
                </div>
            </body>
        </html>
    else
        <html lang="en">
            <head>
                <title>{$format-name}</title>
                <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
                <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
                <link rel="stylesheet" type="text/css" href="{app:resource("tagclouds.css", "css")}"/>
                <link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/dojo/1.9.1/dijit/themes/claro/claro.css" media="screen"/>
                
                <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/dojo/1.9.1/dojo/dojo.js"
                    data-dojo-config="async: true, parseOnLoad: true"/>
                <script>require(["dojo/parser", "dijit/form/ComboBox"]);</script>
                <script>
                    var graphJson = '{vsm:get-spec-json($format)}';
                    
                    document.addEventListener('DOMContentLoaded', function() {{
                    window.onload = init();
                    }});
                
                     function init(){{
                         checkActiveRI();
                         createTags();
                         drawGraph(graphJson,'500','300','-200');
                     }}
                </script>
                
                <script type="text/javascript" src="{app:resource("d3.v2.js", "js")}"/>
                <script type="text/javascript" src="{app:resource("forcegraph.js", "js")}"/>
                <script type="text/javascript" src="{app:resource("tagcanvas.min.js", "js")}"/>
                <script type="text/javascript" src="{app:resource("tagclouds.js", "js")}"/>
                <script type="text/javascript" src="{app:resource("tinymce/tinymce.min.js", "js")}"/>
                <script type="text/javascript" src="{app:resource("xmleditor.js", "js")}"/>
                <script type="text/javascript" src="{app:resource("utils.js", "js")}"/>
                <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
            </head>
            <body>
            <!-- <body onload="createTags();drawGraph('{vsm:get-spec-json($format)}','500','300','-200')">-->
                <div id="all">
                    <div class="logoheader"/>
                    {menu:view()}
                    <div class="content">
                        <div class="navigation"> &gt;
                            <a href="{app:link("views/list-formats.xq")}">Data Deposition Formats</a> &gt;
                            <a href="{app:link(concat("views/view-format.xq?id=", $id))}">{$format-name}</a>
                        </div>
                        <div class="title">
                            <span id="nametext">{$format-name}</span>
                        </div>
                        
                        <div style="float:right; text-align:right">
                                <a href="{app:getGithubFormatIssueLink($id)}" class="button" 
                                    style="padding: 5px 5px 2px 5px; color:darkred; border-color:darkred">
                                    suggest a fix or extension</a>
                        </div>
                        
                        <div>
                            <span class="heading">Abbreviation: </span>
                            <span id="abbrtext" class="heading">
                                {$format-abbr}</span>
                                
                         { if($is-umbrella) then <div style="width:550px">
                        <p>&#9730;&#x00A0;&#x00A0;{$format-abbr} is considered an <b>umbrella format</b>, which means that it is 
                        impossible to create a meaningful recommendation for or against using it, because in the 
                        context of research data, it is actually shorthand for many, sometimes drastically differing formats. 
                        Centres are advised to discern between the various subformats that are grouped 
                        under the general umbrella of this one, for the purpose of creating 
                        recommendations (see the description at the <a href="#desctext{$id}">bottom of this page</a>).</p>
                        <p>Umbrella formats do not appear in the list of 
                        <a href="{app:link("views/list-popular-formats.xq")}">popular formats</a> (unconditionally) 
                        and are indicated as out-of-place (improperly used) in the recommendations – unless they 
                        are qualified by a comment.</p></div>
                                      else () }
                        </div>
                        
                        <div>
                            <span class="heading">Identifiers: </span>
                        </div>
                        <table width= "400px">
                            <tr>
                                <th width="100px">Type</th>
                                <th width="100px">Id</th>
                                <td></td>
                            </tr>
                            <tr>
                                <td class="recommendation-row">SIS ID</td>
                                <td class="recommendation-row">{$id}
                                </td>
                                <td>
                                    {app:create-copy-button($id,$id,"Copy ID to clipboard", "SIS ID copied")}
                                </td>
                            </tr>    
                            {vfm:print-identifiers($format/extId)}
                        </table>
                        {
                        if (count($format/extDoc)) then
                        (<div>
                            <span class="heading">External documents: </span>
                        </div> ,
                        <table width="400px">
                            <tr>
                                <th width="100px">Source</th>
                                <th width="100px">Title</th>
                                <td></td>
                            </tr>
                            {vfm:print-identifiers($format/extDoc)}
                         </table>)
                         else ()
                         }
                        {vfm:print-multiple-values($format/titleStmt/versionNumber, $id, "Versions:")}
                        {
                        if ($format/mimeType) 
                            then
                            <div><span class="heading"><a href="{app:link("views/list-mimetypes.xq")}">Media type(s)</a>:</span></div>
                            else ()
                         }
                        {vfm:print-bullets($format/mimeType, $id)}
                        {vfm:print-multiple-values($format/fileExt, $id, ("File extension(s):","views/list-extensions.xq"))}
                        {vfm:print-multiple-values($format/formatFamily, $id, ("Format family:","views/format-families.xq"))}
                        {vfm:print-multiple-values($format/schemaLoc, $id, "Schema location:", fn:true())}
                        
                        {if (count($format-domains)>0)
                                then(
                                    <div>
                                        <span class="heading"><a href="{app:link("views/list-domains.xq")}">Functional domains</a> extracted from the recommendations: </span>
                                        <div style="column-count:1">
                                            <ul style="margin: 0; padding-left:15px;">
                                                {
                                                    for $d in $format-domains
                                                    order by $d
                                                    return <li><a href="{app:link(concat("views/recommended-formats-with-search.xq?searchFormat=",$id,
                                                    "&amp;searchButton=Search&amp;centre=&amp;domain=",domain:get-id-by-name($d),"&amp;level=&amp;sortBy=#filterRecommendation"))}">{$d}</a></li>
                                                    
                                                    (:return <li><a href="{app:link(concat("views/recommended-formats-with-search.xq?searchFormat=",fPDF,"&amp;searchButton=Search&amp;centre=&amp;domain=",21,"&amp;level=&amp;sortBy=#filterRecommendation))}">{$d}</a></li>:)
                                                    (:return <li>{$d}</li>:)
                                                }
                                                </ul>
                                        </div>
                                    </div>
                                    
                                )
                                else ()}
                        
                        {vfm:print-recommendation-table($id,$domain,$centre,$recommendationType,
                            $sortBy,$language)}
                        <div>
                            <span id="desctext{$id}" class="heading">Description: </span>
                            <span class="desctext">{$format/info[@type = "description"]}</span>
                        </div>
<!--
                        <div align="right"><p><a href="{app:getGithubFormatIssueLink($id)}">[suggest a fix or extension]</a></p></div>
      -->                  
                        {vfm:print-multiple-values($format/keyword, $id, "Keywords:")}
                        <!--The tag cloud of the standard related keywords -->
                        <div id="myCanvasContainer" style="border: 1px solid #DDDDDD; border-radius:3px; align:centre">
                            <canvas width="650" height="250" id="myCanvas"/>
                        </div>
                        <div id="tags" style="display:none">
                            <a style="font-size:22px" onclick="return false">{$format-abbr}</a>
                            {vfm:print-keyword-links($format)}
                        </div>
                        
                        {vsm:print-spec-relation($format,$id, fn:true())}
                        {vsm:print-graph($format)}
                    </div>
                    <div class="footer">{app:footer()}</div>
                </div>
            </body>
        </html>