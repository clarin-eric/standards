xquery version "3.0";

module namespace vfm = "http://clarin.ids-mannheim.de/standards/view-format";

import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace recommendation = "http://clarin.ids-mannheim.de/standards/recommendation-model" 
at "../model/recommendation-by-centre.xqm";
import module namespace domain = "http://clarin.ids-mannheim.de/standards/domain" at "../model/domain.xqm";
import module namespace lp = "http://clarin.ids-mannheim.de/standards/landing-page" at "../model/landing-page.xqm";


import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace rf="http://clarin.ids-mannheim.de/standards/recommended-formats" at "recommended-formats.xql";
import module namespace dm = "http://clarin.ids-mannheim.de/standards/domain-module" at "../modules/domain.xql";

declare function vfm:get-format($id as xs:string) {
    format:get-format($id)
};

declare function vfm:print-identifiers($extIdList){
    for $extId in $extIdList
    let $id := $extId/text()
    let $type := data($extId/@type)
    let $landing-page := $lp:locations[type=$type]
    let $url-suffix := $landing-page/suffix/text()
    let $url := 
        if ($url-suffix) 
        then concat ($landing-page/prefix/text(), $id,$url-suffix)
        else concat ($landing-page/prefix/text(), $id)
    return
        <tr>
            <td class="recommendation-row">{$type}</td>
            <td class="recommendation-row"><a href="{$url}">{$id}</a></td>
        </tr>
};

declare function vfm:print-bullets($list,$id){
    let $items := for $item in $list 
    return <li>{$item}</li>
    
    return <ul>{$items}</ul>
};

declare function vfm:print-multiple-values($list, $id, $label) {
    vfm:print-multiple-values($list, $id, $label, fn:false())
};

declare function vfm:print-multiple-values($list, $id, $label, $isLink as xs:boolean) {
    let $numOfItems := count($list)
    let $max := fn:max(($numOfItems, 1))
    return
        if ($list)
        then
            (
            <div><span class="heading">{$label}&#160;</span>
                <span id="keytext">
                    {
                        for $k in (1 to $numOfItems)
                        return
                            (
                            if ($isLink) then
                                (<a href="{$list[$k]}">{$list[$k]}</a>)
                            else
                                $list[$k]/text(),
                            (:if ($list[$k]/@type)
                            then
                                (<span id="abbrinternalText" style="margin-left:5px;">({data($list[$k]/@type)})</span>)
                            else
                                (),:)
                            if ($list[$k][@recommended = "yes"])
                            then
                                (<span id="abbrinternalText" style="font-size:10px;margin-left:5px;">[recommended]</span>)
                            else
                                (),
                            if ($k = $numOfItems) then
                                ()
                            else
                                ", "
                            )
                    }
                </span>
            </div>
            )
        else
            ()
};

declare function vfm:print-recommendation-in-clarin($format,$format-id){
    let $recommendations := $format/ClarinRecommendation/recommendation
    let $n := count($recommendations)
    return 
        if ($recommendations)
        then 
            <div><span class="heading">Use in CLARIN: </span>
            {for $i in 1 to $n
                let $id := data($recommendations[$i]/@formatId)
                let $link := concat("views/view-format.xq?id=",$format-id,"#",$id)
                let $type := data($recommendations[$i]/@type)
             return 
                if ($format-id = $id)
                then $type
                else (<a href="{app:link($link)}">{vfm:get-format($id)/titleStmt/abbr/text()}</a>, 
                    concat(" (",$type,")",if ($i < $n) then ", " else ()))
            }
           </div>
       else ()
};

declare function vfm:print-recommendation-table($id,$domain,$centre,$recommendationType,$sortBy){
    let $recommendations := recommendation:get-recommendations-for-format($id)
    return
    if ($recommendations)
    then(
        <div>
            <span class="heading" id="recommendationTable">Recommendation: </span>
        </div>,
        <table cellspacing="4px" style="width:97%">
            <tr>
                <th class="header" style="width:15%;">
                    <a href="{
                                app:link(concat("views/view-format.xq?id=", $id ,"&amp;sortBy=centre#recommendationTable"))
                            }">Clarin Centre</a>
                </th>
                <th class="header" style="width:30%;">
                    <a href="{
                                app:link(concat("views/view-format.xq?id=", $id ,"&amp;sortBy=domain#recommendationTable"))
                            }">Domain</a></th>
                <th class="header" style="width:15%;">
                    <a href="{
                                app:link(concat("views/view-format.xq?id=", $id ,"&amp;sortBy=recommendation#recommendationTable"))
                            }">
                        Level</a></th>
                <th class="header" style="width:40%;">
                Comments
                </th>
            </tr>
         {vfm:print-recommendation-rows($recommendations,$id,$sortBy)}
        </table>
        )
    else ()
};

declare function vfm:print-recommendation-rows($recommendations,$format-id,$sortBy){
    for $r in $recommendations
        let $centre := $r/header/filter/centre/text()
        let $formats := $r/formats/format[@id=$format-id]
        
        for $format in $formats
            let $level := $format/level/text()
            let $domainName := $format/domain/text()
            let $domain := 
                if ($domainName) then 
                    dm:get-domain-by-name($domainName) 
                else ()
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
                        ()
            return rf:print-recommendation-row($format, $centre,$domain, fn:false())
};
