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
import module namespace dm = "http://clarin.ids-mannheim.de/standards/domain-module" at "../modules/domain.xql";


declare function rf:print-centres($centre) {
    let $depositing-centres := $centre:centres[@deposition = "1" or @deposition = "true"]
    for $c in data($depositing-centres/@id)
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
    for $d in $domain:domains
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

declare function rf:print-centre-recommendation($requestedCentre, $requestedDomain, $requestedLevel, $sortBy) {
    
    for $r in $recommendation:centres
    let $centre := $r/header/filter/centre/text()
    
    for $format in $r/formats/format
    let $domainName := $format/domain/text()
    let $domain := if ($domainName) then
        dm:get-domain-by-name($domainName)
    else ()
    
    let $level := $format/level/text()
    let $format-id := data($format/name/@id)
    let $format-abbr := $format/name/text()
    let $format-info := $format/info/text()
        
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
                    $format, $centre, $domain))
                else
                    (
                    if ($requestedLevel)
                    then
                        (rf:checkRequestedLevel($requestedLevel, $format, $centre, $domain))
                    else
                        (rf:print-recommendation-row($format, $centre, $domain))
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
                $format, $centre, $domain))
            else
                (
                if ($requestedLevel)
                then
                    (rf:checkRequestedLevel($requestedLevel, $format, $centre, $domain))
                else
                    (rf:print-recommendation-row($format, $centre, $domain))
                )
            )

};

declare function rf:checkRequestedDomain($requestedDomain, $requestedLevel,
$format, $centre, $domain) {
    
    if ($requestedDomain eq data($domain/@id))
    then
        (
        if ($requestedLevel)
        then
            (rf:checkRequestedLevel($requestedLevel, $format, $centre, $domain))
        else
            (rf:print-recommendation-row($format, $centre, $domain))
        )
    else
        ()
};

declare function rf:checkRequestedLevel($requestedLevel, $format, $centre, $domain) {
    
    if ($requestedLevel eq $format/level/text())
    then
        (rf:print-recommendation-row($format, $centre, $domain))
    else
        ()

};

declare function rf:print-recommendation-row($format, $centre, $domain) {
    rf:print-recommendation-row($format, $centre, $domain, fn:true())

};

declare function rf:print-recommendation-row($format, $centre, $domain, $includeFormat) {
    
    let $format-id := data($format/name/@id)
    let $format-abbr := $format/name/text()
    let $format-abbr := if ($format-abbr) then
        $format-abbr
    else
        ($format-id)
    
    let $level := $format/level/text()
    let $format-comment := $format/comment/text()
    
    let $domainId := data($domain/@id)
    let $domainName := $domain/name/text()
    let $domainDesc := $domain/desc/text()
    
    return
        <tr>
            {
                if ($includeFormat) then
                    <td
                        class="recommendation-row"
                        id="{$format-id}"><a
                            href="{app:link(concat("views/view-format.xq?id=", $format-id))}
                ">{$format-abbr}</a></td>
                else
                    ()
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
            <td
                class="tooltip">{
                    if ($format-comment) then
                        (
                        <img
                            src="{app:resource("info.png", "img")}"
                            height="20"/>,
                        <span
                            class="tooltiptext"
                            style="left: 78%; width:300px;">{$format-comment}
                        </span>)
                    else
                        ()
                }
            </td>
        </tr>
};

declare function rf:export-table($centre, $domainId, $requestedLevel, $nodes, $filename) {
    let $domain := dm:get-domain($domainId)
    let $domainName := $domain/name/text()
    let $filter :=
    (if ($centre) then
        <centre>{$centre}</centre>
    else
        (),
    if ($domainName) then
        <domain>{$domainName}</domain>
    else
        (),
    if ($requestedLevel) then
        <level>{$requestedLevel}</level>
    else
        ())
    
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
                    (:<domain
                            id="{$row/td[3]/@id}">{$row/td[3]/text()}</domain>:)
                    <domain>{$row/td[3]/text()}</domain>
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
                <filter>{$filter}</filter>
            </header>
            <formats>{$rows}</formats>
        </result>

};
