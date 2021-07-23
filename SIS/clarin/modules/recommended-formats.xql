xquery version "3.0";

module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats";

import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace centre = "http://clarin.ids-mannheim.de/standards/centre" at "../model/centre.xqm";

import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace rm = "http://clarin.ids-mannheim.de/standards/recommendation" at "../modules/recommendation.xql";

(:deprecated
declare function rf:print-recommendation($type) {
    let $ids := format:get-all-ids()
    for $id in $ids
    let $format-abbr := $format:formats[@id = $id]/titleStmt/abbr/text()
    let $recommendations := format:get-recommendations($id)
    let $typeNumber :=
    if ($type = "recommended") then
        "1"
    else
        if ($type = "acceptable") then
            "2"
        else
            if ($type = "deprecated") then
                "3"
            else
                "0"
    
    for $r in $recommendations
    let $centre := data($r/parent::node()/@id)
    for $values in fn:tokenize($r, "\.")
    let $size := fn:string-length($values)
    let $recommendationLevel := fn:substring($values, $size)
    let $domainId := fn:substring($values, 1, $size - 1)
    let $domain := $format:domains[@id = $domainId]/text()
    return
        if ($recommendationLevel = $typeNumber)
        then
            <tr>
                <td class="recommendation-row"><a href="{app:link(concat("views/view-format.xq?id=", $id))}">{$format-abbr}</a></td>
                <td class="recommendation-row">{$centre}</td>
                <td class="recommendation-row">{$domain}</td>
            </tr>
        else
            ()
};
:)
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

(: deprecated
declare function rf:print-domains($path) {
    let $size := count($format:domains)
    let $lastDomain := $format:domains[$size]
    
    for $domain in $format:domains
    let $url := app:link(concat("views/", $path, ".xq?domain=", $domain))
    let $link := <a href="{$url}">{$domain}</a>
    return
        if ($domain ne $lastDomain)
        then
            ($link, " | ")
        else
            ($link)
};:)

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

declare function rf:print-recommendation($requestedCentre, $requestedDomain, $requestedType, $sortBy) {
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
    let $rType := rf:print-recommendation-level($recommendationLevel)
        
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
                    (rf:checkRequestedDomain($requestedDomain, $requestedType, $recommendationLevel,
                    $id, $format-abbr, $centre, $domainId, $domainName, $domainDesc, $rType))
                else
                    (
                    if ($requestedType)
                    then
                        (rf:checkRequestedType($requestedType, $recommendationLevel, $id,
                        $format-abbr, $centre, $domainName, $domainDesc, $rType))
                    else
                        (rf:print-recommendation-row($id, $format-abbr, $centre, $domainName,
                        $domainDesc, $rType))
                    )
                )
            else
                ()
            )
        else
            (
            if ($requestedDomain)
            then
                (rf:checkRequestedDomain($requestedDomain, $requestedType, $recommendationLevel,
                $id, $format-abbr, $centre, $domainId, $domainName, $domainDesc, $rType))
            else
                (
                if ($requestedType)
                then
                    (rf:checkRequestedType($requestedType, $recommendationLevel, $id,
                    $format-abbr, $centre, $domainName, $domainDesc, $rType))
                else
                    (rf:print-recommendation-row($id, $format-abbr, $centre, $domainName,
                    $domainDesc, $rType))
                )
            )

};

declare function rf:checkRequestedDomain($requestedDomain, $requestedType, $recommendationLevel,
$id, $format-abbr, $centre, $domainId, $domainName, $domainDesc, $rType) {
    
    if ($requestedDomain eq $domainId)
    then
        (
        if ($requestedType)
        then
            (rf:checkRequestedType($requestedType, $recommendationLevel, $id, $format-abbr,
            $centre, $domainName, $domainDesc, $rType))
        else
            (rf:print-recommendation-row($id, $format-abbr, $centre, $domainName, $domainDesc,
            $rType))
        )
    else
        ()
};

declare function rf:checkRequestedType($requestedType, $recommendationLevel, $id, $format-abbr, 
$centre, $domainName, $domainDesc, $rType) {
    
    if ($requestedType eq $recommendationLevel)
    then
        (rf:print-recommendation-row($id, $format-abbr, $centre, $domainName, $domainDesc, $rType))
    else
        ()

};

declare function rf:print-recommendation-row($id, $format-abbr, $centre, $domainName, $domainDesc,  
$rType) {
    <tr>
        <td class="recommendation-row"><a href="{app:link(concat("views/view-format.xq?id=", $id))}
            ">{$format-abbr}</a></td>
        <td class="recommendation-row">{$centre}</td>
        <td class="recommendation-row tooltip">{$domainName}<span class="tooltiptext">{$domainDesc}
            </span></td>
        <td class="recommendation-row">{$rType}</td>
    </tr>
};

declare function rf:export-table($centre, $domainId, $recommendationType, $nodes, $filename) {
    let $domainName := $format:domains[@id = $domainId]/name/text()

    let $rows :=
    for $row in $nodes
    return
        <format>
            <name>{$row/td[1]/a/text()}</name>
            <centre>{$row/td[2]/text()}</centre>
            <domain>{$row/td[3]/text()}</domain>
            <level>{$row/td[4]/text()}</level>
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
                    <level>{rf:print-recommendation-level($recommendationType)}</level>
                </filter>
            </header>
            <formats>{$rows}</formats>
        </result>

};

(:declare function rf:getRecommendationForFormat($recommendations, $sortBy) {
    for $r in $recommendations
    let $centre := data($r/parent::node()/@id)
    for $values in fn:tokenize($r, "\.")
    let $size := fn:string-length($values)
    let $recommendationLevel := fn:substring($values, $size)
    let $rType := rf:print-recommendation-level($recommendationLevel)
    let $domainId := fn:substring($values, 1, $size - 1)
    let $domainName := $format:domains[@id = $domainId]/name/text()
    
    
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
                ()
    return
        <tr>
            <td class="recommendation-row">{$centre}</td>
            <td class="recommendation-row">{$domainName}</td>
            <td class="recommendation-row">{$rType}</td>
        </tr>
};
:)