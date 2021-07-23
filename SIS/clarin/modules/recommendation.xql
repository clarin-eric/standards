xquery version "3.0";

module namespace rm="http://clarin.ids-mannheim.de/standards/recommendation";

import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace sb="http://clarin.ids-mannheim.de/standards/standardbody" at "../model/sb.xqm";
import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";
import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace centre="http://clarin.ids-mannheim.de/standards/centre" at "../model/centre.xqm";

(:  Define standard-relation functions
    @author margaretha
    @lastUpdate March 2021
:)

declare function rm:print-recTypes($path){
    for $type in xsd:get-clarinRecTypes()
    let $t :=
        if ($type = 'fully recommended') then 'recommended'
        else $type
        
    let $url := app:link(concat("views/",$path,".xq?type=",$t))        
    return    
        if ($t != 'deprecated') then (<a href="{$url}">{$type}</a>," | ")
        else <a href="{$url}">{$type}</a>        
};

declare function rm:translate-type($type){
    if ($type = 'recommended') then 'fully recommended'
        else $type    
};

declare function rm:print-recTable($type){
    let $recType := rm:translate-type($type)        
    let $recommendations:= $spec:specs/ClarinRecommendation/recommendation[@type=$recType]
    
    return
        for $rec in $recommendations
            let $spec := $rec/ancestor::node()
            let $rec-node := $spec/descendant-or-self::node()[@id = $rec/@specId]
            let $rec-abbr := $rec-node/titleStmt/abbr/text()
            let $style := "border-bottom:1px solid #DDDDDD; text-align:left; vertical-align:top;"
        order by $rec-abbr 
        return
            <tr>
                <td style= "{$style}">{rm:get-recommendation-link($rec-abbr, $spec/@id, $rec/@specId)}</td>
                <td style= "{$style}">{rm:get-recommendation-sb($spec/@standardSettingBody)}</td>
                <td style= "{$style}" >{rm:get-clarin-centres($rec-node)}</td>
                <td style= "{$style}">{rm:get-alternatives($rec)}</td>
                <!--<td style= "{$style}">{$rec/info[@type="description"]}</td>-->
            </tr>
};

declare function rm:get-clarin-centres($rec-node){
    let $clarin-centres := spec:get-clarin-centres($rec-node)
    let $num-of-centres := count($clarin-centres)
    
    for $i in 1 to $num-of-centres
        let $id := $clarin-centres[$i]
         let $c := <a href="{centre:get-centre($id)/a/@href}">{$id}</a>
    return 
        if ($i < $num-of-centres)
        then ($c, ', ')
        else <a href="{centre:get-centre($id)/a/@href}">{$id}</a>
};

declare function rm:get-alternatives($rec){
    let $alternatives := $rec/alternatives/alternative/@specId
    let $n := count($alternatives)
    return  
        for $i in 1 to $n
            let $alt-id := data($alternatives[$i])
            let $alt-node := $spec:specs/descendant-or-self::node()[@id=$alt-id]
            let $link := 
                if ($alt-node/@standardSettingBody) 
                then app:link(concat("views/view-spec.xq?id=",$alt-id))
                else app:link(concat("views/view-spec.xq?id=",$alt-node/@id,"#",$alt-id))                    
            return (<a href="{$link}">{$alt-node/titleStmt/abbr}</a>, if ($i < $n) then ", " else ())
};

declare function rm:get-recommendation-sb($sb-id){
    let $sb-abbr := sb:get-sb($sb-id)/titleStmt/abbr/text()
    let $sb-url := app:link(concat("views/view-sb.xq?id=",$sb-id))
    return <a href ="{$sb-url}">{$sb-abbr}</a>
};

declare function rm:get-recommendation-link($rec-abbr, $spec-id, $rec-id){    
    let $rec-url := app:link(concat("views/view-spec.xq?id=",$spec-id,"#",$rec-id))
    return <a href="{$rec-url}">{$rec-abbr}</a>
};