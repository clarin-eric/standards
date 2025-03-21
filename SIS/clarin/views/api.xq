xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";


<html lang="en">
    <head>
        <title>API</title>
        <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
    </head>
    <body>
        <div id="all">
            <div class="logoheader"/>
            {menu:view()}
            <div class="content">
                <div class="navigation">&gt; <a href="{app:link("views/api.xq")}">API</a></div>
                <div><span class="title">REST API</span></div>
                
                <div>
                    <p>The CLARIN Standards Information System provides REST API that can be accessed at
                        <a href="https://clarin.ids-mannheim.de/standards/rest/">
                            https://clarin.ids-mannheim.de/standards/rest/</a>.</p>
                </div>
                
                <div style="margin-top:30px;"><span class="subtitle">Retrieving centre recommendations</span>
                    <hr/>
                    <p><span class="heading">Method: </span> GET</p>
                    <p><span class="heading">Service URL: </span>
                        <code>https://clarin.ids-mannheim.de/standards/rest/data/recommendations/[centre-id]-recommendation.xml</code></p>
                    <p>Recommendations of a centre can be simply retrieved by replacing <code>[centre-id]</code> with a centre identifier listed at
                        <a href="{app:link("views/list-centre.xq")}">the centre page</a>.
                    </p>
                    <p><span class="heading">Example using curl:</span></p>
                    <p>
                        <code>
                            curl 'https://clarin.ids-mannheim.de/standards/rest/data/recommendations/IDS-recommendation.xml'
                        </code>
                    </p>
                </div>
                
                <div style="margin-top:30px;"><span class="subtitle">Exporting recommendations</span>
                    <hr/>
                    <p><span class="heading">Method: </span> GET</p>
                    <p><span class="heading">Service URL: </span>
                        <code>https://clarin.ids-mannheim.de/standards/rest/views/recommended-formats-with-search.xq</code>
                    </p>
                    <p><span class="heading">Query parameters:</span>
                    </p>
                    <table>
                        <tr style="vertical-align:top">
                            <th>Name</th>
                            <th>Required</th>
                            <th style="width:50%;">Description</th>
                            <th>Example</th>
                        </tr>
                        <tr style="vertical-align:top">
                            <td class="row">centre</td>
                            <td class="row">no</td>
                            <td class="row">a centre identifier, see <a href="{app:link("views/list-centre.xq")}">the centre page</a></td>
                            <td class="row">IDS</td>
                        </tr>
                        <tr style="vertical-align:top">
                            <td class="row">domain</td>
                            <td class="row">no</td>
                            <td class="row">a domain identifier, see <a href="#retrieving-domains">Retrieving domains</a></td>
                            <td class="row">1</td>
                        </tr>
                        <tr style="vertical-align:top">
                            <td class="row">level</td>
                            <td class="row">no</td>
                            <td class="row">a recommendation level: <code>recommended</code>, <code>acceptable</code>
                                or <code>discouraged</code></td>
                            <td class="row">recommended</td>
                        </tr>
                        <tr style="vertical-align:top">
                            <td class="row">export</td>
                            <td class="row">yes</td>
                            <td class="row">determines if the export should be done</td>
                            <td class="row">yes</td>
                        </tr>
                        <tr style="vertical-align:top">
                            <td class="row">ri</td>
                            <td class="row">no</td>
                            <td class="row">filter the recommendations by research infrastructure. The value must be URL-encoded. 
                            Possible values: Text+, CLARIN (default)</td>
                            <td class="row">Text%2B</td>
                        </tr>
                    </table>
                    
                    <p><span class="heading">Example using curl:</span></p>
                    <p>
                        <code>
                            curl 'https://clarin.ids-mannheim.de/standards/rest/views/recommended-formats-with-search.xq?
                            centre=IDS&amp;domain=1&amp;level=recommended&amp;ri=Text%2B&amp;export=yes'
                        </code>
                    </p>
                </div>
                
                <div style="margin-top:30px;"><span class="subtitle">Retrieving format descriptions</span>
                    <hr/>
                    <p><span class="heading">Method: </span> GET</p>
                    <p><span class="heading">Service URL: </span>
                        <code>https://clarin.ids-mannheim.de/standards/rest/data/formats/[formatId].xml</code>
                    </p>
                    <p>A format descriptions can be retrieved by replacing <code>[format-id]</code> with a format identifier
                        that can be copied at the <a href="{app:link("views/list-formats.xq")}">data deposition formats</a> page.
                    </p>
                    <p><span class="heading">Example using curl:</span></p>
                    <p>
                        <code>
                            curl 'https://clarin.ids-mannheim.de/standards/rest/data/formats/fCHAT.xml'
                        </code>
                    </p>
                </div>
                
                <div id="retrieving-domains" style="margin-top:30px;"><span class="subtitle">Retrieving domains</span>
                    <hr/>
                    <p><span class="heading">Method: </span> GET</p>
                    <p><span class="heading">Service URL: </span>
                        <code><a href="https://clarin.ids-mannheim.de/standards/rest/data/domains.xml">
                                https://clarin.ids-mannheim.de/standards/rest/data/domains.xml</a></code>
                    </p>
                    <p><span class="heading">Example using curl:</span></p>
                    <p>
                        <code>
                            curl 'https://clarin.ids-mannheim.de/standards/rest/data/domains.xml'
                        </code>
                    </p>
                </div>
                
                <!--
                <div id="retrieving-centres" style="margin-top:30px;"><span class="subtitle">Retrieving centres</span>
                    <hr/>
                    <p><span class="heading">Method: </span> GET</p>
                    <p><span class="heading">Service URL: </span>
                        <code><a href="https://clarin.ids-mannheim.de/standards/rest/data/centres.xml">
                                https://clarin.ids-mannheim.de/standards/rest/data/centres.xml</a></code>
                    </p>
                    <p><span class="heading">Example using curl:</span></p>
                    <p>
                        <code>
                            curl 'https://clarin.ids-mannheim.de/standards/rest/data/centres.xml'
                        </code>
                    </p>
                </div>
                -->
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>