xquery version "3.0";

module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats";

import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace centre = "http://clarin.ids-mannheim.de/standards/centre" at "../model/centre.xqm";
import module namespace domain = "http://clarin.ids-mannheim.de/standards/domain" at "../model/domain.xqm";
import module namespace recommendation = "http://clarin.ids-mannheim.de/standards/recommendation-model" 
at "../model/recommendation-by-centre.xqm";

import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace rm = "http://clarin.ids-mannheim.de/standards/recommendation" at "../modules/recommendation.xql";


declare function rf:print-centres($centre) {
    for $c in data($centre:centres/@id)
        order by fn:lower-case($c)
    return
        if ($c eq $centre)
        then
            (<option
                value="{$c}"
                selected="selected">{$c}</option>)
        else
            (<option
                value="{$c}">{$c}</option>)
};

declare function rf:print-domains($domainId) {
    for $d in $format:domains
    let $id := $d/@id
        order by fn:lower-case($d/name/text())
    return
        if ($id eq $domainId)
        then
            <option
                value="{$id}"
                selected="selected"
                title="{$d/desc/text()}">{$d/name/text()}</option>
        else
            <option
                value="{$id}"
                title="{$d/desc/text()}">{$d/name/text()}</option>
};

declare function rf:print-option($selected, $value, $label) {
    if ($selected eq $value)
    then
        <option
            value="{$value}"
            selected="selected">{$label}</option>
    else
        <option
            value="{$value}">{$label}</option>
};

(:@deprecated:)
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

declare function rf:print-centre-recommendation($requestedCentre, $requestedDomain, $requestedLevel, $sortBy) {
    
    for $r in $recommendation:centres
        let $centre := $r/header/filter/centre/text()
        
        for $format in $r/formats/format
            let $domainId :=$format/domain/@id
            let $domainName := $format/domain/text()
            let $domainDesc := $domain:domains[@id = $domainId]/desc/text()
            let $level := $format/level/text()
            let $format-abbr:=$format/name/text()
            let $format-id := data($format/name/@id)
        
        order by
        if ($sortBy = 'centre') then
            $centre
        else
            if ($sortBy = 'domain') then
                $domainName
            else
                if ($sortBy = 'recommendation') then
                    $level
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
                    (rf:checkRequestedDomain($requestedDomain, $requestedLevel,
                    $format-id, $format-abbr, $centre, $domainId, $domainName, $domainDesc, $level))
                else
                    (
                    if ($requestedLevel)
                    then
                        (rf:checkRequestedLevel($requestedLevel, $format-id,
                        $format-abbr, $centre, $domainId, $domainName, $domainDesc, $level))
                    else
                        (rf:print-recommendation-row($format-id, $format-abbr, $centre, $domainId, $domainName,
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
                (rf:checkRequestedDomain($requestedDomain, $requestedLevel,
                $format-id, $format-abbr, $centre, $domainId, $domainName, $domainDesc, $level))
            else
                (
                if ($requestedLevel)
                then
                    (rf:checkRequestedLevel($requestedLevel, $format-id,
                    $format-abbr, $centre, $domainId, $domainName, $domainDesc, $level))
                else
                    (rf:print-recommendation-row($format-id, $format-abbr, $centre, $domainId, $domainName,
                    $domainDesc, $level))
                )
            )

};

declare function rf:checkRequestedDomain($requestedDomain, $requestedLevel,
$format-id, $format-abbr, $centre, $domainId, $domainName, $domainDesc, $level) {
    
    if ($requestedDomain eq $domainId)
    then
        (
        if ($requestedLevel)
        then
            (rf:checkRequestedLevel($requestedLevel, $format-id, $format-abbr,
            $centre, $domainId, $domainName, $domainDesc, $level))
        else
            (rf:print-recommendation-row($format-id, $format-abbr, $centre, $domainId, $domainName, $domainDesc,
            $level))
        )
    else
        ()
};

declare function rf:checkRequestedLevel($requestedLevel, $format-id, $format-abbr,
$centre, $domainId, $domainName, $domainDesc, $level) {
    
    if ($requestedLevel eq $level)
    then
        (rf:print-recommendation-row($format-id, $format-abbr, $centre, $domainId, $domainName, $domainDesc, $level))
    else
        ()

};

declare function rf:print-recommendation-row($format-id, $format-abbr, $centre, $domainId, $domainName, $domainDesc,
$level) {
    rf:print-recommendation-row($format-id, $format-abbr, $centre, $domainId, $domainName, $domainDesc,
$level, fn:true())

};

declare function rf:print-recommendation-row($format-id, $format-abbr, $centre, $domainId, $domainName, $domainDesc,
$level, $includeFormat) {
    <tr>
        {if ($includeFormat) then
        <td
            class="recommendation-row"
            id="{$format-id}"><a
                href="{app:link(concat("views/view-format.xq?id=", $format-id))}
            ">{$format-abbr}</a></td>
            else ()
        }
        <td
            class="recommendation-row">{$centre}</td>
        <td
            class="recommendation-row tooltip"
            id="{$domainId}">{$domainName}<span
                class="tooltiptext">{$domainDesc}
            </span></td>
        <td
            class="recommendation-row">{$level}</td>
    </tr>
};

declare function rf:export-table($centre, $domainId, $requestedLevel, $nodes, $filename) {
    let $domainName := $format:domains[@id = $domainId]/name/text()
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
                    <domain
                        id="{$row/td[3]/@id}">{$row/td[3]/text()}</domain>
                else
                    (),
                if ($requestedLevel eq "") then
                    (<level>{$row/td[4]/text()}</level>)
                else
                    ()
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
