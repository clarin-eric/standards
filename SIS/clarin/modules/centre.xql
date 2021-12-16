xquery version "3.0";

module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module";
import module namespace centre = "http://clarin.ids-mannheim.de/standards/centre" at "../model/centre.xqm";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace recommendation = "http://clarin.ids-mannheim.de/standards/recommendation-model"
at "../model/recommendation-by-centre.xqm";

import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "recommended-formats.xql";
import module namespace dm = "http://clarin.ids-mannheim.de/standards/domain-module" at "domain.xql";


declare function cm:get-centre($id) {
    centre:get-centre($id)
};

declare function cm:list-centre() {
    for $c in $centre:centres
    let $id := data($c/@id)
    let $status-text := data($c/nodeInfo/ri/@status)
    let $statuses :=
    if (fn:contains($status-text, ","))
    then
        <span>{
                for $status in fn:tokenize(data($c/nodeInfo/ri/@status), ",")
                return
                    ($status, <br/>)
            }
        </span>
    else
        $status-text
    
    order by fn:lower-case($id)
    return
        <tr>
            <td class="recommendation-row"><a href="{app:link(concat("views/view-centre.xq?id=", $id))}">{$id}</a></td>
            <td class="recommendation-row">{$c/name/text()}</td>
            <td class="recommendation-row">{$c/nodeInfo/ri/text()}</td>
            <td class="recommendation-row">{$statuses}</td>
        </tr>
};

declare function cm:print-recommendation-table($id, $sortBy) {
    let $recommendation := recommendation:get-recommendations-for-centre($id)
    let $path := concat('/db/apps/clarin/data/recommendations', $id, "-recommendation.xml")
    return
        if (count($recommendation/formats/format)>0)
        then
            (
            <div>
                <span class="heading" id="recommendationTable">Recommendations: </span>
            </div>,
            
            <table cellspacing="4px" style="width:97%">
                <tr>
                    <th class="header" style="width:15%;">
                        <a href="{
                                    app:link(concat("views/view-centre.xq?id=", $id, "&amp;sortBy=format#recommendationTable"))
                                }">Format</a>
                    </th>
                    <th class="header" style="width:30%;">
                        <a href="{
                                    app:link(concat("views/view-centre.xq?id=", $id, "&amp;sortBy=domain#recommendationTable"))
                                }">Domain</a></th>
                    <th class="header" style="width:15%;">
                        <a href="{
                                    app:link(concat("views/view-centre.xq?id=", $id, "&amp;sortBy=recommendation#recommendationTable"))
                                }">
                            Level</a></th>
                    <th class="header" style="width:40%;">
                        Comments
                    </th>
                </tr>
                {cm:print-recommendation-rows($recommendation, $id, $sortBy)}
            </table>
            )
        else
            ()
};

declare function cm:print-recommendation-rows($recommendation, $centre-id, $sortBy) {
    for $format in $recommendation/formats/format
        let $format-id := data($format/@id)
        let $format-obj := format:get-format($format-id)
        let $format-abbr := $format-obj/titleStmt/abbr/text()
        let $level := $format/level/text()
        let $domainName := $format/domain/text()
        let $domain :=
            if ($domainName) then
                dm:get-domain-by-name($domainName)
            else ()
            
        order by
        if ($sortBy = 'format') then
            (if ($format-abbr) then fn:lower-case($format-abbr) else fn:lower-case(fn:substring($format-id,2)))
        else
            if ($sortBy = 'domain') then
                $domainName
            else
                if ($sortBy = 'recommendation') then
                    $level
                else (:by format:)
                    (if ($format-abbr) then fn:lower-case($format-abbr) else fn:lower-case(fn:substring($format-id,2)))
    return 
        rf:print-recommendation-row($format, $centre-id, $domain, fn:true(), fn:false())
};
