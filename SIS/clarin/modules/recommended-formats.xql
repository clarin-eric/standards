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
    let $domainNumber := fn:substring($values, 1, $size - 1)
    let $domain := $format:domains[@id = $domainNumber]/text()
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

declare function rf:print-centers() {
    for $c in data($center:centers/@id)
    return
        <option value="{$c}">{$c}</option>
};

declare function rf:print-domains() {
    for $d in $format:domains
    return
        <option value="{$d}">{$d}</option>
};

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
    let $domainNumber := fn:substring($values, 1, $size - 1)
    let $domain := $format:domains[@id = $domainNumber]/text()
    
    let $rType :=
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
                    (rf:checkRequestedDomain($requestedDomain, $requestedType, $recommendationNumber, $id, $format-abbr, $centre, $domain, $rType))
                else
                    (
                    if ($requestedType)
                    then
                        (rf:checkRequestedType($requestedType, $recommendationNumber, $id, $format-abbr, $centre, $domain, $rType))
                    else
                        (rf:print-recommendation-row($id, $format-abbr, $centre, $domain, $rType))
                    )
                )
            else
                ()
            )
        else
            (
            if ($requestedDomain)
            then
                (rf:checkRequestedDomain($requestedDomain, $requestedType, $recommendationNumber, $id, $format-abbr, $centre, $domain, $rType))
            else
                (
                if ($requestedType)
                then
                    (rf:checkRequestedType($requestedType, $recommendationNumber, $id, $format-abbr, $centre, $domain, $rType))
                else
                    (rf:print-recommendation-row($id, $format-abbr, $centre, $domain, $rType))
                )
            )

};

declare function rf:checkRequestedDomain($requestedDomain, $requestedType, $recommendationNumber, $id, $format-abbr, $centre, $domain, $rType) {
    if ($requestedDomain eq $domain)
    then
        (
        if ($requestedType)
        then
            (rf:checkRequestedType($requestedType, $recommendationNumber, $id, $format-abbr, $centre, $domain, $rType))
        else
            (rf:print-recommendation-row($id, $format-abbr, $centre, $domain, $rType))
        )
    else
        ()
};

declare function rf:checkRequestedType($requestedType, $recommendationNumber, $id, $format-abbr, $centre, $domain, $rType) {
    
    if ($requestedType eq $recommendationNumber)
    then
        (rf:print-recommendation-row($id, $format-abbr, $centre, $domain, $rType))
    else
        ()

};

declare function rf:print-recommendation-row($id, $format-abbr, $centre, $domain, $rType) {
    <tr>
        <td class="recommendation-row"><a href="{app:link(concat("views/view-format.xq?id=", $id))}">{$format-abbr}</a></td>
        <td class="recommendation-row">{$centre}</td>
        <td class="recommendation-row">{$domain}</td>
        <td class="recommendation-row">{$rType}</td>
    </tr>
};

declare function rf:export-table($nodes, $filename){
    let $rows :=  
        for $row in $nodes
        return 
        <recommendation>
            <format>{$row/td[1]/a/text()}</format>
            <centre>{$row/td[2]/text()}</centre>
            <domain>{$row/td[3]/text()}</domain>
            <level>{$row/td[4]/text()}</level>
        </recommendation>

    (:let $isExportSuccessful := file:serialize($data, $filename,fn:false()):)
    let $quote := "&#34;"
    let $header1 := response:set-header("Content-Disposition", concat("attachment; filename=",$quote,$filename,$quote))
    let $header2 := response:set-header("Content-Type","text/xml;charset=utf-8")
    
    return <recommendations>{$rows}</recommendations>
};

declare function rf:getRecommendationForFormat($recommendations, $sortBy) {
    for $r in $recommendations
    let $centre := data($r/parent::node()/@id)
    for $values in fn:tokenize($r, "\.")
    let $size := fn:string-length($values)
    let $recommendationNumber := fn:substring($values, $size)
    let $domainNumber := fn:substring($values, 1, $size - 1)
    let $domain := $format:domains[@id = $domainNumber]/text()
    
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
                else ()
    return
        <tr>
            <td class="recommendation-row">{$centre}</td>
            <td class="recommendation-row">{$domain}</td>
            <td class="recommendation-row">{$rType}</td>
        </tr>
};
