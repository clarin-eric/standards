xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";


<html>
    <head>
        <title>API</title>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        <script type="text/javascript" src="{app:resource("session.js", "js")}"/>"/>
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
                        <tr>
                            <th>Name</th>
                            <th>Required</th>
                            <th style="width:50%;">Description</th>
                            <th>Example</th>
                        </tr>
                        <tr>
                            <td>centre</td>
                            <td>no</td>
                            <td>a centre identifier, see <a href="{app:link("views/list-centre.xq")}">the centre page</a></td>
                            <td>IDS</td>
                        </tr>
                        <tr>
                            <td>domain</td>
                            <td>no</td>
                            <td>a domain identifier, see <a href="#retrieving-domains">Retrieving domains</a></td>
                            <td>1</td>
                        </tr>
                        <tr>
                            <td>level</td>
                            <td>no</td>
                            <td>a recommendation level: <code>recommended</code>, <code>acceptable</code>
                                or <code>discouraged</code></td>
                            <td>recommended</td>
                        </tr>
                        <tr>
                            <td>export</td>
                            <td>yes</td>
                            <td>determine if the export should be done</td>
                            <td>yes</td>
                        </tr>
                    </table>
                    
                    <p><span class="heading">Example using curl:</span></p>
                    <p>
                        <code>
                            curl 'https://clarin.ids-mannheim.de/standards/rest/views/recommended-formats-with-search.xq?centre=IDS&amp;domain=1&amp;level=recommended&amp;export=yes'
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
            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>