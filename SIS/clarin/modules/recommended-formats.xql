xquery version "3.0";

module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats";

import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace centre = "http://clarin.ids-mannheim.de/standards/centre" at "../model/centre.xqm";

import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace rm = "http://clarin.ids-mannheim.de/standards/recommendation" at "../modules/recommendation.xql";


declare function rf:print-centres($centre) {
    for $c in data($centre:centres/@id)
    order by fn:lower-case($c)
    return
        if ($c eq $centre)
        then
        (<option value="{$c}" selected="selected">{$c}</option>)
        else
        (<option value="{$c}">{$c}</option>)
};

declare function rf:print-domains($domainId) {
    for $d in $format:domains
    let $id := $d/@id
    order by fn:lower-case($d/name/text())
    return
        if ($id eq $domainId)
        then
        <option value="{$id}" selected="selected" title="{$d/desc/text()}">{$d/name/text()}</option>
        else 
        <option value="{$id}" title="{$d/desc/text()}">{$d/name/text()}</option>
};

declare function rf:print-option($selected, $value,$label) {
    if ($selected eq $value)
    then 
    <option value="{$value}" selected="selected">{$label}</option>
    else 
    <option value="{$value}">{$label}</option>
};

declare function rf:print-recommendation-level($recommendationLevel) {
    if ($recommendationLevel = "r") then
        "recommended"
    else
        (
        if ($recommendationLevel = "a") then
            "acceptable"
        else
            if ($recommendationLevel = "d") then
                "deprecated"
            else
                ""
        )
};

declare function rf:print-recommendation($requestedCentre, $requestedDomain, $requestedLevel, $sortBy) {
    let $ids := format:get-all-ids()
    
    for $id in $ids
    let $format-abbr := $format:formats[@id = $id]/titleStmt/abbr/text()
    let $recommendations := format:get-recommendations($id)
    for $r in $recommendations
    let $centre := data($r/parent::node()/@id)
    for $values in fn:tokenize($r, "\.")
    let $size := fn:string-length($values)
    let $recommendationLevel := fn:substring($values, $size)
    let $domainId := fn:substring($values, 1, $size - 1)
    let $domainName := $format:domains[@id = $domainId]/name/text()
    let $domainDesc := $format:domains[@id = $domainId]/desc/text()
    let $level := rf:print-recommendation-level($recommendationLevel)
        
        order by
        if ($sortBy = 'centre') then
            $centre
        else
            if ($sortBy = 'domain') then
                $domainName
            else
                if ($sortBy = 'recommendation') then
                    $recommendationLevel
                else
                    (fn:lower-case($format-abbr)) (:abbr:)
    
    return
        if ($requestedCentre)
        then
            (
            if ($requestedCentre eq $centre)
            then
                (
                if ($requestedDomain)
                then
                    (rf:checkRequestedDomain($requestedDomain, $requestedLevel, $recommendationLevel,
                    $id, $format-abbr, $centre, $domainId, $domainName, $domainDesc, $level))
                else
                    (
                    if ($requestedLevel)
                    then
                        (rf:checkRequestedLevel($requestedLevel, $recommendationLevel, $id,
                        $format-abbr, $centre, $domainId, $domainName, $domainDesc, $level))
                    else
                        (rf:print-recommendation-row($id, $format-abbr, $centre, $domainId, $domainName,
                        $domainDesc, $level))
                    )
                )
            else
                ()
            )
        else
            (
            if ($requestedDomain)
            then
                (rf:checkRequestedDomain($requestedDomain, $requestedLevel, $recommendationLevel,
                $id, $format-abbr, $centre, $domainId, $domainName, $domainDesc, $level))
            else
                (
                if ($requestedLevel)
                then
                    (rf:checkRequestedLevel($requestedLevel, $recommendationLevel, $id,
                    $format-abbr, $centre, $domainId, $domainName, $domainDesc, $level))
                else
                    (rf:print-recommendation-row($id, $format-abbr, $centre, $domainId, $domainName,
                    $domainDesc, $level))
                )
            )

};

declare function rf:checkRequestedDomain($requestedDomain, $requestedLevel, $recommendationLevel,
$id, $format-abbr, $centre, $domainId, $domainName, $domainDesc, $level) {
    
    if ($requestedDomain eq $domainId)
    then
        (
        if ($requestedLevel)
        then
            (rf:checkRequestedLevel($requestedLevel, $recommendationLevel, $id, $format-abbr,
            $centre, $domainId, $domainName, $domainDesc, $level))
        else
            (rf:print-recommendation-row($id, $format-abbr, $centre, $domainId, $domainName, $domainDesc,
            $level))
        )
    else
        ()
};

declare function rf:checkRequestedLevel($requestedLevel, $recommendationLevel, $id, $format-abbr, 
$centre, $domainId, $domainName, $domainDesc, $level) {
    
    if ($requestedLevel eq $recommendationLevel)
    then
        (rf:print-recommendation-row($id, $format-abbr, $centre, $domainId, $domainName, $domainDesc, $level))
    else
        ()

};

declare function rf:print-recommendation-row($id, $format-abbr, $centre, $domainId, $domainName, $domainDesc,  
$level) {
    <tr>
        <td class="recommendation-row" id="{$id}"><a href="{app:link(concat("views/view-format.xq?id=", $id))}
            ">{$format-abbr}</a></td>
        <td class="recommendation-row">{$centre}</td>
        <td class="recommendation-row tooltip" id="{$domainId}">{$domainName}<span class="tooltiptext">{$domainDesc}
            </span></td>
        <td class="recommendation-row">{$level}</td>
    </tr>
};

declare function rf:export-table($centre, $domainId, $requestedLevel, $nodes, $filename) {
    let $domainName := $format:domains[@id = $domainId]/name/text()
    let $requestedLevel := rf:print-recommendation-level($requestedLevel)
    let $rows :=
    for $row in $nodes
    return
        <format>
            <name
                id="{$row/td[1]/@id}">{$row/td[1]/a/text()}</name>
            {
                if ($centre eq "") then
                    <centre>{$row/td[2]/text()}</centre>
                else
                    (),
                if ($domainId eq "") then
                    <domain id="{$row/td[3]/@id}">{$row/td[3]/text()}</domain>
                else
                    (),
                if ($requestedLevel eq "") then 
                    (<level>{$row/td[4]/text()}</level>)
                else ()     
            }
            
        </format>
        
        (:let $isExportSuccessful := file:serialize($data, $filename,fn:false()):)
    let $quote := "&#34;"
    let $header1 := response:set-header("Content-Disposition", concat("attachment; filename=", 
        $quote, $filename, $quote))
    let $header2 := response:set-header("Content-Type", "text/xml;charset=utf-8")
    
    return
        <result>
            <header>
                <title>CLARIN Standards Information System (SIS) export</title>
                <url>{app:link("views/recommended-formats-with-search.xq")}</url>
                <date>{fn:current-dateTime()}</date>
                <filter>
                    <centre>{$centre}</centre>
                    <domain>{$domainName}</domain>
                    <level>{$requestedLevel}</level>
                </filter>
            </header>
            <formats>{$rows}</formats>
        </result>

};
