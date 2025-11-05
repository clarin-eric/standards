xquery version "3.1";

import module namespace menu = "http://clarin.ids-mannheim.de/standards/menu" at "../modules/menu.xql";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace centre = "http://clarin.ids-mannheim.de/standards/centre" at "../model/centre.xqm";
import module namespace recommendation = "http://clarin.ids-mannheim.de/standards/recommendation-model" at "recommendation-by-centre.xqm";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "../modules/recommended-formats.xql";


declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";
declare option output:html-version "5";

(: 
    @author margaretha, bansp
:)

let $ri := app:get-ri()
let $language := app:determine-language($ri)
let $rows as element(tr)* := for $r in $recommendation:centres[header/respStmt/name ne '']
            let $brief := data($r/header/centre/@id)
            let $cur as element(name)+ := $r/header/respStmt/name
            let $date as element(reviewDate)+ := $r/header/respStmt/reviewDate
            let $comm := $r/header/lastUpdateCommitID
            order by $brief
            return 
            <tr style="vertical-align:top">
            <td><a href="{app:link(concat("views/view-centre.xq?id=", $brief))}">{$brief}</a></td>
            <td style="padding-bottom:0.5em">{for $l in $cur
                 return ($l, <br />)
            }</td>
            <td>{for $l in $date
                 return (rf:paint-curation-date(string($l),$language,true()), <br />)
            }</td>
            <td style="font-family:monospace; font-size: 0.9em"><a href="{concat('https://github.com/clarin-eric/standards/commit/',$comm)}">{substring($comm,1,8)}</a></td>
            </tr>

return 
<html lang="en">
    <head>
        <title>Centre Curation</title>
        <link rel="icon" type="image/x-icon" href="{app:favicon()}"/>
        <link rel="stylesheet" type="text/css" href="{app:resource("style.css", "css")}"/>
        <script type="text/javascript" src="{app:resource("edit.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("utils.js", "js")}"/>
        <script type="text/javascript" src="{app:resource("session.js", "js")}"/>
    </head>
    <body>
        <div id="all">
            <div class="logoheader"/>
            {menu:view()}
            <div class="content">
                <div class="navigation">
                    &gt; <a href="{app:link("views/list-centres.xq")}">Centres</a>
                    &gt; <a href="{app:link("views/list-curators.xq")}">Centre Curation</a>
                </div>
                <div class="title">Centre Curation</div>

                    <div><p>Curation of data implies cyclic review and potential modification. Given the pace at which our 
                    field progresses and the changing standards landscape, we suggest that, after a year, "it wouldn't be bad"
                    to review a centre's recommendations, although, in many cases, nothing needs to change after that time. 
                    The orange colouring of dates older than a year is basically a signal that, after a few more blinks of 
                    an eye, it may be worth to ask the colleagues responsible for the local data management and archiving 
                    if anything has changed (perhaps a new format has appeared and/or an older format is not as much 
                    recommended as it used to be, etc.).</p>
                    <p>The red colour is a signal that two years have passed and perhaps those DM colleagues should be 
                    contacted just in case. The exclamation mark is not so much to add a sense of urgency as rather to serve 
                    as a way to mark those longer periods when, for any reason, colour-coding won't work. The "Last commit" 
                    column can be treated as mostly internal information: we try to make it reflect the last commit that 
                    significantly changed the information content of a centre's recommendation list.</p>
                    <p>The list below only shows the {count($rows)} <i> curated</i> centres. To get a broader view, please
                    turn to the full <a href="{app:link("views/list-centres.xq")}">list of centres</a>.</p>
                    </div>

                    <table id ="curation-table" style="width:600px">
                        <tr>
                            <th class="header" style="width:30%;">Centre by ID</th>
                            <th class="header" style="width:30%;">Curator(s)</th>
                            <th class="header" style="width:20%;">Date stamp</th>
                            <th class="header" style="width:20%;">Last commit</th>
                        </tr>
                        {$rows}
                    </table>

            </div>
            <div class="footer">{app:footer()}</div>
        </div>
    </body>
</html>
