xquery version "3.0";

module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats";

import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace center = "http://clarin.ids-mannheim.de/standards/center" at "../model/center.xqm";

import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace rm = "http://clarin.ids-mannheim.de/standards/recommendation" at "../modules/recommendation.xql";

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
    let $recommendationNumber := fn:substring($values, $size)
    let $domainId := fn:substring($values, 1, $size - 1)
    let $domain := $format:domains[@id = $domainId]/text()
    return
        if ($recommendationNumber = $typeNumber)
        then
            <tr>
                <td class="recommendation-row"><a href="{app:link(concat("views/view-format.xq?id=", $id))}">{$format-abbr}</a></td>
                <td class="recommendation-row">{$centre}</td>
                <td class="recommendation-row">{$domain}</td>
            </tr>
        else
            ()
};

declare function rf:print-centers($center) {
    for $c in data($center:centers/@id)
    return
        if ($c eq $center)
        then
        (<option value="{$c}" selected="selected">{$c}</option>)
        else
        (<option value="{$c}">{$c}</option>)
};

declare function rf:print-domains($domainId) {
    for $d in $format:domains
    let $id := $d/@id
    return
        if ($id eq $domainId)
        then
        <option value="{$id}" selected="selected">{$d/name/text()}</option>
        else 
        <option value="{$id}">{$d/name/text()}</option>
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

declare function rf:print-recommendation-level($recommendationNumber) {
    if ($recommendationNumber = "1") then
        "recommended"
    else
        (
        if ($recommendationNumber = "2") then
            "acceptable"
        else
            if ($recommendationNumber = "3") then
                "deprecated"
            else
                ""
        )
};

declare function rf:print-recommendation($requestedCenter, $requestedDomain, $requestedType, $sortBy) {
    let $ids := format:get-all-ids()
    
    for $id in $ids
    let $format-abbr := $format:formats[@id = $id]/titleStmt/abbr/text()
    let $recommendations := format:get-recommendations($id)
    for $r in $recommendations
    let $centre := data($r/parent::node()/@id)
    for $values in fn:tokenize($r, "\.")
    let $size := fn:string-length($values)
    let $recommendationNumber := fn:substring($values, $size)
    let $domainId := fn:substring($values, 1, $size - 1)
    let $domainName := $format:domains[@id = $domainId]/name/text()
    let $domainDesc := $format:domains[@id = $domainId]/desc/text()
    let $rType := rf:print-recommendation-level($recommendationNumber)
        
        order by
        if ($sortBy = 'centre') then
            $centre
        else
            if ($sortBy = 'domain') then
                $domainName
            else
                if ($sortBy = 'recommendation') then
                    $recommendationNumber
                else
                    (fn:lower-case($format-abbr)) (:abbr:)
    
    return
        if ($requestedCenter)
        then
            (
            if ($requestedCenter eq $centre)
            then
                (
                if ($requestedDomain)
                then
                    (rf:checkRequestedDomain($requestedDomain, $requestedType, $recommendationNumber,
                    $id, $format-abbr, $centre, $domainId, $domainName, $domainDesc, $rType))
                else
                    (
                    if ($requestedType)
                    then
                        (rf:checkRequestedType($requestedType, $recommendationNumber, $id,
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
                (rf:checkRequestedDomain($requestedDomain, $requestedType, $recommendationNumber,
                $id, $format-abbr, $centre, $domainId, $domainName, $domainDesc, $rType))
            else
                (
                if ($requestedType)
                then
                    (rf:checkRequestedType($requestedType, $recommendationNumber, $id,
                    $format-abbr, $centre, $domainName, $domainDesc, $rType))
                else
                    (rf:print-recommendation-row($id, $format-abbr, $centre, $domainName,
                    $domainDesc, $rType))
                )
            )

};

declare function rf:checkRequestedDomain($requestedDomain, $requestedType, $recommendationNumber,
$id, $format-abbr, $centre, $domainId, $domainName, $domainDesc, $rType) {
    
    if ($requestedDomain eq $domainId)
    then
        (
        if ($requestedType)
        then
            (rf:checkRequestedType($requestedType, $recommendationNumber, $id, $format-abbr,
            $centre, $domainName, $domainDesc, $rType))
        else
            (rf:print-recommendation-row($id, $format-abbr, $centre, $domainName, $domainDesc,
            $rType))
        )
    else
        ()
};

declare function rf:checkRequestedType($requestedType, $recommendationNumber, $id, $format-abbr, 
$centre, $domainName, $domainDesc, $rType) {
    
    if ($requestedType eq $recommendationNumber)
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

declare function rf:export-table($center, $domainId, $recommendationType, $nodes, $filename) {
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
                    <center>{$center}</center>
                    <domain>{$domainName}</domain>
                    <level>{rf:print-recommendation-level($recommendationType)}</level>
                </filter>
            </header>
            <formats>{$rows}</formats>
        </result>

};

declare function rf:getRecommendationForFormat($recommendations, $sortBy) {
    for $r in $recommendations
    let $centre := data($r/parent::node()/@id)
    for $values in fn:tokenize($r, "\.")
    let $size := fn:string-length($values)
    let $recommendationNumber := fn:substring($values, $size)
    let $domainId := fn:substring($values, 1, $size - 1)
    let $domain := $format:domains[@id = $domainId]/text()
    
    let $rType :=
    if ($recommendationNumber = "1") then
        "recommended"
    else
        if ($recommendationNumber = "2") then
            "acceptable"
        else
            if ($recommendationNumber = "3") then
                "deprecated"
            else
                ""
        order by
        if ($sortBy = 'centre') then
            $centre
        else
            if ($sortBy = 'domain') then
                $domain
            else
                if ($sortBy = 'recommendation') then
                    $recommendationNumber
                else
                    ()
    return
        <tr>
            <td class="recommendation-row">{$centre}</td>
            <td class="recommendation-row">{$domain}</td>
            <td class="recommendation-row">{$rType}</td>
        </tr>
};
