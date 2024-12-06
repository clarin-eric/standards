xquery version "3.0";

module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats";

import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace centre = "http://clarin.ids-mannheim.de/standards/centre" at "../model/centre.xqm";
import module namespace domain = "http://clarin.ids-mannheim.de/standards/domain" at "../model/domain.xqm";
import module namespace recommendation = "http://clarin.ids-mannheim.de/standards/recommendation-model"
at "../model/recommendation-by-centre.xqm";
import module namespace data = "http://clarin.ids-mannheim.de/standards/data" at "../model/data.xqm";

import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace dm = "http://clarin.ids-mannheim.de/standards/domain-module" at "../modules/domain.xql";

import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

declare variable $rf:pageSize := 50;
declare variable $rf:searchMap := rf:getSearchMap();

declare function rf:isCurated($recommendation){
    let $respStmt := $recommendation/header/respStmt
    let $respName := string($respStmt[1]/name)
    return 
        if ($respName) then true() else false()
};

declare function rf:print-curation($recommendation, $language) {
   if (rf:isCurated($recommendation))
   then
        (
        <div>
            <span class="heading">Curation: </span>
            {
                for $rs in $recommendation/header/respStmt
                let $resp := functx:capitalize-first($rs/resp/text())
                return
                    (
                    <ul>
                        <li>{if ($resp) then concat($resp,": ") else (),
                            
                                if (empty($rs/link/text()))
                                then
                                    (<span>{$rs/name/text()}</span>)
                                else
                                    (
                                    <a href="{$rs/link/text()}">{$rs/name/text()}</a>)
                            }
                            <span> ({
                                    format-date($rs/reviewDate/text(),
                                    "[MNn] [D], [Y]", $language, (), ())
                                })</span>
                        </li>
                    </ul>
                    )
            }
        </div>
        )
    else
        (
        <div>
            <span class="heading" style="color:darkred">Warning: </span>
            <span style="color:darkred">The recommendations have not been curated yet.</span>
        </div>
        )
};

declare function rf:getSearchMap() {
    let $fids := distinct-values(($recommendation:format-ids, $format:ids))
    let $fabbrs := distinct-values(($recommendation:format-abbrs, $format:abbrs))
    
    (: $centre:names problematic:)
    let $formatIdMap := for $item in $fids
    return
        map:entry($item, "fid")
    let $formatAbbrMap := for $item in $fabbrs
    return
        map:entry($item, "fabbr")
    let $formatNameMap := for $item in $format:titles
    return
        map:entry($item, "fname")
    let $centreIdMap := for $item in $centre:ids
    return
        map:entry($item, "cid")
    let $domainMap := for $item in $domain:names
    return
        map:entry($item, "dname")
    let $searchMap := map:merge(($formatIdMap, $formatAbbrMap, $formatNameMap, $centreIdMap, $domainMap))
    return
        $searchMap
        (:map:get($searchMap,"DANS"):)
};

declare function rf:countFid() {
    (count($recommendation:format-ids),
    count(distinct-values(($recommendation:format-ids, $format:ids))))
};

declare function rf:listSearchSuggestions() {
    (: $centre:names problematic:)
    let $fids := distinct-values(($recommendation:format-ids, $format:ids))
    let $fabbrs := distinct-values(($recommendation:format-abbrs, $format:abbrs))
    
    let $union :=
    for $item in ($fids, $fabbrs, $format:titles, $centre:ids, $domain:names)
        order by fn:lower-case($item)
    return
        $item
    
    return
        fn:string-join($union, ",")
};

declare function rf:listSearchSuggestions($recommendations) {
    let $recommendationTable :=
    util:deep-copy(<table>{$recommendations}</table>)
    
    let $fids := data($recommendationTable/tr/td[1]/@id)
    let $fabbrs := $recommendationTable/tr/td[1]/a/text()
    let $centre := $recommendationTable/tr/td[2]/a/text()
    let $domains := $recommendationTable/tr/td[3]/span/text()
    
    let $union :=
    for $item in ($fids, $fabbrs, $centre, $domains)
        order by fn:lower-case($item)
    return
        $item
    
    let $union := distinct-values($union)
    return
        fn:string-join($union, ",")
};

declare function rf:searchFormat($searchItem, $rows) {
    let $category := map:get($rf:searchMap, $searchItem)
    return
        if ($category eq "fid")
        then
            $rows[td[1]/@id = $searchItem]
        
        else
            if ($category eq "fabbr")
            then
                $rows[td[1]/text() = $searchItem or td[1]/a/text() = $searchItem]
                
                (: else if ($category eq "fname")
        then rf:searchFormatByName($searchItem):)
            
            else
                if ($category eq "cid")
                then
                    $rows[td[2]/a/text() = $searchItem]
                    (:then rf:print-centre-recommendation($searchItem,(),'',''):)
                
                else
                    if ($category eq "dname")
                    then
                        $rows[td[3]/span/text() = $searchItem]
                    else
                        ()
};


declare function rf:print-page-links($numOfRows, $sortBy, $domainId, $recommendationLevel, $centre, $page as xs:int) {
    let $numberOfPages := xs:integer(fn:ceiling($numOfRows div $rf:pageSize))
    
    for $i in (1 to $numberOfPages)
    let $pageLink := <a
        href="{
                app:link(concat("views/recommended-formats-with-search.xq?sortBy=",
                $sortBy,
                (:"&amp;domain=",:)
                $domainId, "&amp;level=", $recommendationLevel,
                "&amp;centre=", $centre, "&amp;page=", $i, "#searchRecommendation"))
            }">{$i}</a>
    return
        if ($i = $page) then
            $page
        else
            if ($i < $page)
            then
                ($pageLink, " < ")
            else
                (" > ", $pageLink)

};

declare function rf:print-page-navigation($numberOfPages, $sortBy, $domainId, 
    $recommendationLevel, $centre, $currentPage as xs:int){
    
    let $nextLink :=
        if ($currentPage = $numberOfPages) then ()
        else ( 
            rf:create-page-link($sortBy, $domainId, $recommendationLevel, $centre, 
            $currentPage +1, " >>")
        )
    let $prevLink := 
        if ($currentPage = 1) then () 
        else ( 
                rf:create-page-link($sortBy, $domainId, $recommendationLevel, $centre,
               $currentPage -1, "<< ")
       )
    return ($prevLink, concat($currentPage ,"/",$numberOfPages), $nextLink)
};

declare function rf:create-page-link($sortBy, $domainId, $recommendationLevel, $centre, 
$page as xs:int, $label) {
    <a href="{
                app:link(concat("views/recommended-formats-with-search.xq?sortBy=",
                $sortBy,
                (:"&amp;domain=",:)
                $domainId, "&amp;level=", $recommendationLevel,
                "&amp;centre=", $centre, "&amp;page=", $page, "#searchRecommendation"))
            }">{$label}</a>
};

declare function rf:paging($rows, $page as xs:int) {
    let $numOfRows := count($rows)
    
    let $max := fn:min(($numOfRows, $page * $rf:pageSize)) + 1
    let $min := if ($page > 1) then
        (($page - 1) * $rf:pageSize)
    else 1
    
    return
        $rows[position() >= $min and position() < $max]
};

declare function rf:print-centres($centre,$ri) {
    let $depositing-centres := 
        if ($ri eq "all") 
        then $centre:centres 
        else centre:get-deposition-centres($ri)
        
    for $c in data($depositing-centres/@id)
        order by fn:lower-case($c)
    return
        rf:print-option($centre,$c,$c)
};

declare function rf:print-domains($domains) {
    for $d in $domain:domains
    let $id := $d/@id
        order by fn:lower-case($d/name/text())
    return
        if (functx:is-value-in-sequence($id, $domains))
        then
            <option
                value="{$id}"
                selected="selected">{$d/name/text()}</option>
        else
            <option
                value="{$id}">{$d/name/text()}</option>
};

declare function rf:print-keywords($keyword) {
    for $k in $format:keywords
        order by fn:lower-case($k)
    return
        rf:print-option($keyword,$k,$k)
};

declare function rf:print-option($selected, $value, $label) {
    if (empty($selected))
    then
        <option value="{$value}">{$label}</option>
    else
        if ($selected eq $value)
        then
            <option
                value="{$value}"
                selected="selected">{$label}</option>
        else
            <option
                value="{$value}">{$label}</option>
};

declare function rf:print-centre-recommendation($requestedCentre, 
    $requestedDomain as xs:string*,$requestedLevel, $sortBy, 
    $language, $ri) {

    let $ri-centres := centre:get-centre-ids-by-ri($ri)
          
    let $ri-recommendations := 
        if ($ri eq "all") then ($recommendation:centres)
        else $recommendation:centres[contains($ri-centres, 
        header/filter/centreID/text())]
    
    for $r in $ri-recommendations
        let $centre := $r/header/filter/centreID/text()
        for $format in $r/formats/format
        let $domainName := $format/domain/text()
        let $domain :=
            if ($domainName)
            then
                dm:get-domain-by-name($domainName)
            else
                ()
            
        let $level := $format/level/text()
        let $format-id := data($format/@id)
        let $format-abbr := $format:formats[@id = $format-id]/titleStmt/abbr/text()
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
                        (if ($format-abbr) then
                            fn:lower-case($format-abbr)
                        else
                            fn:lower-case(fn:substring($format-id, 2))) (:abbr:)
        
        return
            
            if ($requestedCentre)
            then
                (
                if ($requestedCentre eq $centre)
                then
                    (
                    if (not(empty($requestedDomain)))
                    then
                        (rf:checkRequestedDomain($requestedDomain, $requestedLevel,
                        $format, $centre, $domain, $language))
                    else
                        (
                        if ($requestedLevel)
                        then
                            (rf:checkRequestedLevel($requestedLevel, $format, $centre, $domain, $language))
                        else
                            (rf:print-recommendation-row($format, $centre, $domain, $language))
                        )
                    )
                else
                    ()
                )
            else
                (
                if (not(empty($requestedDomain)))
                then
                    (rf:checkRequestedDomain($requestedDomain, $requestedLevel,
                    $format, $centre, $domain, $language))
                else
                    (
                    if ($requestedLevel)
                    then
                        (rf:checkRequestedLevel($requestedLevel, $format, $centre, $domain, $language))
                    else
                        (rf:print-recommendation-row($format, $centre, $domain, $language))
                    )
                )
};

declare function rf:checkRequestedDomain($requestedDomain, $requestedLevel,
$format, $centre, $domain, $language) {
    
    if (functx:is-value-in-sequence(data($domain/@id), $requestedDomain))
    then
        (
        
        if ($requestedLevel)
        then
            (rf:checkRequestedLevel($requestedLevel, $format, $centre, $domain, $language))
        else
            (rf:print-recommendation-row($format, $centre, $domain, $language))
        )
    else
        ()
};

declare function rf:checkRequestedLevel($requestedLevel, $format, $centre, $domain, $language) {
    
    if ($requestedLevel eq $format/level/text())
    then
        (rf:print-recommendation-row($format, $centre, $domain, $language))
    else
        ()

};

declare function rf:print-recommendation-row($format, $centre, $domain, $language) {
    rf:print-recommendation-row($format, $centre, $domain, $language, fn:true(), fn:true())

};

declare function rf:parseFormatRef($format-comment) {
    if ($format-comment)
    then
        (
        element comment {
            $format-comment/@*,
            for $node in $format-comment/node()
            return
                if ($node/self::formatRef)
                then
                    <a href="{app:link(concat("views/view-format.xq?id=", $node/@ref))}">
                        {substring($node/@ref, 2)}</a>
                else
                    $node
        }
        )
    else
        ()
};

declare function rf:print-recommendation-row($format, $centre, $domain, $language,
$includeFormat, $includeCentre) {
    
    let $format-id := data($format/@id)
    let $format-obj := format:get-format($format-id)
    let $format-abbr := $format-obj/titleStmt/abbr/text()
    let $format-link :=
    if ($format-obj) then
        (
        <a href="{app:link(concat("views/view-format.xq?id=", $format-id))}">
            {
                if ($format-abbr) then
                    $format-abbr
                else
                    $format-id
            }
        </a>
        )
    else(
        fn:substring($format-id, 2),
        rf:print-missing-format-link($format-id)
        )
    
    let $level := $format/level/text()
    let $format-comment := rf:print-format-comments($format, $language)
    
    let $modifiedComment := rf:parseFormatRef($format-comment)
    
    let $domainId := data($domain/@id)
    let $domainName := $domain/name/text()
    let $domainDesc := $domain/desc
    
    return
        <tr>
            {
                if ($includeFormat) then
                    <td
                        class="recommendation-row"
                        id="{$format-id}">
                        {$format-link}
                    </td>
                else
                    ()
            }
            {
                if ($includeCentre)
                then
                    <td class="recommendation-row">{
                            <a href="{app:link(concat("views/view-centre.xq?id=", $centre))}">
                                {$centre}</a>
                        }
                    </td>
                else
                    ()
            }
            <td
                class="recommendation-row"
                id="{$domainId}">
                <span class="tooltip">{$domainName}
                    <span
                        class="tooltiptext" style="left:20%">{$domainDesc}
                    </span>
                </span>
            </td>
            <td
                class="recommendation-row">{$level}</td>
            {
                if ($includeFormat and $includeCentre)
                then
                    (
                    <td class="tooltip">{
                            if ($format-comment) then
                                (
                                <img
                                    src="{app:resource("info.png", "img")}"
                                    height="17"/>,
                                <span
                                    class="tooltiptext"
                                    style="width:200px;">{$modifiedComment}
                                </span>)
                            else
                                ()
                        }
                    </td> (:,
                    <td>
                    {
                    if ($format-obj) 
                        then () 
                        else
                        <a href="{concat('https://github.com/clarin-eric/standards/issues/new?assignees=&amp;labels=SIS%3Aformats%2C+templatic&amp;template=incorrect-missing-format-description.md&amp;title=','Suggestion of a format description for ID="',
                        $format-id,'"')}">
                             <img src="{app:resource("plus.png", "img")}" height="15"/> </a>
                    }
                    </td>:)
                    )
                else (
                    <td
                        class="recommendation-row">
                        {$modifiedComment}
                    </td>
                )
            }
        </tr>
};


declare function rf:print-format-comments($format, $language) {
    let $format-comment :=
    if ($language eq "*") then
        $format/comment
    else
        $format/comment[@xml:lang = $language]
    return
        if ($format-comment) then
            $format-comment
        else
            if ($format/comment[@xml:lang = "en"]) then
                $format/comment[@xml:lang = "en"]
            else
                $format/comment[not(@xml:lang)]
};

declare function rf:print-missing-format-link($format-id) {
    <span class="tooltip">
        <a style="margin-left:5px;" href="{app:getGithubIssueLink($format-id)}">
            <img src="{app:resource("plus.png", "img")}" height="15"/>
        </a>
        <span
            class="tooltiptext"
            style="width:300px;">Click to add or suggest missing format information
        </span>
    </span>
};
