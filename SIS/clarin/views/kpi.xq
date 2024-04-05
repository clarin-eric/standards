xquery version "3.0";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module" at "../modules/centre.xql";

(: 
    @author margaretha, banski
:)

let $depositioncentres := cm:get-deposition-centres("CLARIN")
let $numOfBCentres := fn:count($depositioncentres) 
let $numOfBCentresWithRecommendations := cm:count-number-of-centres-with-recommendations($depositioncentres)
let $percentage := format-number($numOfBCentresWithRecommendations div $numOfBCentres,'0%')

return
    
    
    <html>
        <head>
            <title>Relevant CLARIN KPIs</title>
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
                                <td class="column">Number of certified deposition centres</td>
                                <td class="column">Number of certified deposition centres</td>
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
                                <td class="column">CLARIN deposition centres recorded in the SIS</td>
                                <td class="column">{$numOfBCentres}</td>
                            </tr>
                            <tr>
                                <td class="column">Number of deposition centres that have provided information (and recorded that in the SIS)</td>
                                <td class="column">{$numOfBCentresWithRecommendations}</td>
                            </tr>
                            <tr>
                                <td class="column">KPI "Collections of standards and mappings" as represented in the SIS </td>
                                <td class="column">{$percentage}</td>
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
                            <li>The SIS provides information on all <a href="{app:link("views/list-centres.xq")}">centres that allow
                                    for data depositions</a> (some of them are not B-centres, and some of them may not be CLARIN centres either). That set is wider than the set of
                                <a href="{app:link("views/list-centres.xq?status=B-centre&amp;submit=Filter")}">CLARIN B-centres</a>,
                                which is the basis for the calculation of the CLARIN KPI listed as #2 above.</li>
                        </ul>
                        <p>The third potentially relevant KPI is "Collaboration with RIs", and its measure is "Number of official collaborations with RIs as
                            confirmed in formal agreements". Regarding this KPI, the SIS can provide only indirect and rather imprecise information: it can be gleaned from the number of
                            Research Infrastructures other than CLARIN that the SIS lists information on. More details in this area can be found in
                            <a href="https://www.clarin.eu/content/clarin-and">the relevant section(s) of clarin.eu</a>.</p>
                    </div>
                </div>
                <div class="footer">{app:footer()}</div>
            </div>
        </body>
    </html>
