xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module" at "../modules/centre.xql";
(:import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "recommended-formats.xql";:)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: 
    @author margaretha, banski
:)

let $depositionCentres as element(centre)* := cm:get-deposition-centres("CLARIN")
let $numOfDepositionCentres := fn:count($depositionCentres)
let $curatedCentres as element(header)* := cm:get-curated-centres("CLARIN")
let $numOfCuratedCentres := fn:count($curatedCentres)
let $depositionBCentres as element(centre)* := $depositionCentres[nodeInfo/ri[. eq 'CLARIN'][contains(@status,'B-centre')]]
let $numOfDepositionBCentres := fn:count($depositionBCentres)
let $curatedBCentres as element(header)* := $curatedCentres[centre/nodeInfo/ri[. eq 'CLARIN'][contains(@status,'B-centre')]]
let $numOfCuratedBCentres := fn:count($curatedBCentres)
let $numOfDepositionCentresWithRecommendations := cm:count-number-of-centres-with-recommendations($depositionCentres)
let $percentage := format-number($numOfCuratedCentres div $numOfDepositionCentres,'0%')
let $percentageB := format-number($numOfCuratedBCentres div $numOfDepositionBCentres,'0%')

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
                    <p>Note that, for the time being at last, this page focuses on CLARIN. The SIS is able to provide and calculate statistics for other RIs as well, 
                    as long as there is a need and... sufficient data.</p>
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
                                <td class="column">Number of certified deposition centres</td>
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
                    <div><p>Below, we provide partial data on KPIs #1 and #2, on the basis of the <i>current content of the SIS</i>.</p>
                    
                        <table style="width:600px; border-collapse:collapse;">
                            <tr>
                                <td class="column">(a) All CLARIN <a href="{app:link("views/list-statistics-centre.xq")}">deposition centres</a> recorded in the SIS</td>
                                <td class="column">{$numOfDepositionCentres}</td>
                            </tr>
                            <tr>
                                <td class="column">(b) CLARIN centres that curate their information</td>
                                <td class="column">{$numOfCuratedCentres}</td>
                            </tr>
                            <tr>
                                <td class="column">(c) KPI "Collections of standards and mappings" <i>as represented in the SIS</i></td>
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
                    <p>We can also cite other numbers that can be helpful in finding your way through SIS statistics:</p>
                    <ul>
                    <li>Apart from information that is curated by the individual centres, the SIS also contains partial information on other centres. 
                    That information comes from the time when the then CLARIN Standards Committee (CSC) used calc sheets to store deposition data format recommendations for selected centres. 
                    The overall number of centres that the SIS has <i>some</i> information on is {$numOfDepositionCentresWithRecommendations}. In 
                    other words, the SIS lists {$numOfDepositionCentresWithRecommendations - $numOfCuratedCentres} deposition centres which do not yet curate their information. 
                    The status of each centre with respect to that is visualised in our <a href="{app:link("views/list-centres.xq")}">list of all centres</a>. For more, check 
                    <a href="https://www.clarin.eu/content/standards-and-formats">CLARIN pages</a>.</li>
                    <li>B-centres have a special status in CLARIN. Among the {$numOfDepositionCentres} deposition centres listed by the SIS, {$numOfDepositionBCentres} 
                    are B-centres, and among these, {$numOfCuratedBCentres} centres curate their information. If we look at the percentage of <b>B-centres</b> that already 
                    <b>curate</b> their information in the SIS, the result is much higher: <b>{$percentageB}</b>.</li>
                    </ul>
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
