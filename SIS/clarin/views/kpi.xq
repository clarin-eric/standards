xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module" at "../modules/centre.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: 
    @author margaretha, banski
:)

let $depositioncentres := cm:get-deposition-centres("CLARIN")
let $numOfDepositionCentres := fn:count($depositioncentres) 
let $numOfDepositionCentresWithRecommendations := cm:count-number-of-centres-with-recommendations($depositioncentres)
let $percentage := format-number($numOfDepositionCentresWithRecommendations div $numOfDepositionCentres,'0%')

let $date := fn:current-dateTime()
let $timestamp :=  format-dateTime($date, "[MNn] [D1o], [Y]", "en", (), ())

return
    
    
    <html lang="en">
        <head>
            <title>Relevant CLARIN KPIs</title>
            <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
            <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
            <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
        </head>
        <body>
            <div id="all">
                <div class="logoheader"/>
                {menu:view()}
                <div class="content">
                    <div class="navigation">
                        &gt; <a href="{app:link("views/recommended-formats-with-search.xq")}">Format Recommendations</a>
                        &gt; <a href="{app:link("views/list-statistics.xq")}">Statistics</a>
                        &gt; <a href="{app:link("views/kpi.xq")}">Relevant KPIs</a>
                    </div>
                    <div class="title">Relevant CLARIN KPIs</div>
                    <div>
                        <p>Among the 12 Key Performance Indicators that have been adopted as measures of performance of
                            CLARIN, at least three reference areas that the SIS either draws on or directly serves. The two crucial ones are the following:</p>
                    </div>
                    <div>
                        <table style="width:600px; border-collapse:collapse;">
                            <tr>
                                <th class="column"></th>
                                <th class="column" style="width:200px">Key Performance Indicator</th>
                                <th class="column">Measurement</th>
                            </tr>
                            <tr>
                                <td class="column">1.</td>
                                <td class="column">Number of certified <a href="{app:link("views/list-statistics-centre.xq")}">deposition centres</a></td>
                                <td class="column">Number of certified <a href="{app:link("views/list-statistics-centre.xq")}">deposition centres</a></td>
                            </tr>
                            <tr>
                                <td class="column">2.</td>
                                <td class="column">Collections of standards and mappings</td>
                                <td class="column">Percentage of centres offering repository services that have published an
                                    overview of formats that can be processed in their repository</td>
                            </tr>
                        
                        </table>
                    </div>
                    <div><p>Below, we provide data on KPIs #1 and #2, on the basis of the current content of the SIS.</p>
                    
                        <table style="width:600px; border-collapse:collapse;">
                            <tr>
                                <td class="column">CLARIN <a href="{app:link("views/list-statistics-centre.xq")}">deposition centres</a> recorded in the SIS</td>
                                <td class="column">{$numOfDepositionCentres}</td>
                            </tr>
                            <tr>
                                <td class="column">Number of <a href="{app:link("views/list-statistics-centre.xq")}">deposition centres</a> 
                                    that have provided information (and recorded that in the SIS)</td>
                                <td class="column">{$numOfDepositionCentresWithRecommendations}</td>
                            </tr>
                            <tr>
                                <td class="column">KPI "Collections of standards and mappings" as represented in the SIS </td>
                                <td class="column">{$percentage}</td>
                            </tr>
                            <tr>
                                <td colspan="2" style="padding-top: 10px; text-align:right">Timestamp: {$timestamp}</td>
                            </tr>
                        </table>
                        
                        <!--
                        <ul>
                            <li>CLARIN deposition centres recorded in the SIS: <b>count(cm:get_centres(RI=CLARIN, status=deposition centre))</b>
                            </li>
                            <li>Number of deposition centres that have provided information (and recorded that in the SIS): <b>count( rf:get_centres_where count(/recommendation/formats/* gt 0) )</b></li>
                            <li>KPI "Collections of standards and mappings" as represented in the SIS: <b>100 *
                                    count(rf:get_centres_where count(/recommendation/formats/* gt 0)) /
                                    count(get_centres(RI=CLARIN, status=deposition centre)) %</b></li>
                        </ul>
                        
                        <a href="{app:link("views/list-centres.xq?status=B-centre&amp;submit=Filter")}">CLARIN B-centres</a>
                        -->
                    </div>
                    <div>
                        <p>Please note that:</p>
                        <ul>
                            <li>CLARIN is a dynamic and developing infrastructure: new centres join, existing centres can be disbanded or
                                change their status, and updating that information requires a bit of a time lag.
                                See <a href="https://www.clarin.eu/content/certified-b-centres">the list of certified B-centres</a> at clarin.eu for the most up-to-date information.</li>
                            <li>The SIC and the SIS team have provided this platform for sharing the recommendations but cannot be responsible for inputting them
                                or keeping them current for each centre – that is <a href="https://github.com/clarin-eric/standards/wiki/Updating-format-recommendations">the
                                    role of the centres themselves</a>. If you notice that recommendations from some data-depositing centre are missing, please kindly consider inviting that
                                centre to provide their information to the SIS.</li>
                            <li>The SIS provides information on (among others) all the <a href="{app:link("views/list-centres.xq")}">CLARIN centres that allow
                                    for data depositions</a>. That set is wider than the set of 
                                    <a href="{app:link("views/list-centres.xq?status=B-centre&amp;submit=Filter")}">CLARIN B-centres</a>, and it is the former set 
                                    that constitutes the basis for the calculation of the CLARIN KPI listed as #2 above.</li>
                        </ul>
                    </div>
                </div>
                <div class="footer">{app:footer()}</div>
            </div>
        </body>
    </html>
