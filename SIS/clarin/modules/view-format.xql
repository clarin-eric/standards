xquery version "3.0";

module namespace vfm = "http://clarin.ids-mannheim.de/standards/view-format";

import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";

declare function vfm:get-format($id as xs:string) {
    format:get-format($id)
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
                            if ($list[$k]/@type)
                            then
                                (<span id="abbrinternalText" style="margin-left:5px;">({data($list[$k]/@type)})</span>)
                            else
                                (),
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

declare function vfm:print-recommendation($format,$format-id){
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
