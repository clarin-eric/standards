xquery version "3.0";

module namespace index="http://clarin.ids-mannheim.de/standards/index";
import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace sb="http://clarin.ids-mannheim.de/standards/standardbody" at "../model/sb.xqm";

declare function index:count-frequency($list as item()*, $id as xs:string){
    count (for $item in $list[. = ($id)] return $item)
};

(: Count how many times a spec-version become the target of a relation :)
declare function index:count-version-relations($targets as item()*, $version-id as item()*){
    sum( 
        for $id in $version-id
            return count (for $item in $targets[. = ($id)] return $item)
    )
};

declare function index:count-spec-frequency($spec-id as xs:string, $version-id as item()*){
    let $targets := spec:get-targets()
    let $number-of-spec-relations := index:count-frequency($targets, $spec-id)
    let $number-of-version-relations := index:count-version-relations($targets,$version-id)
    
    return $number-of-spec-relations + $number-of-version-relations    
};

declare function index:print-spec-links() {
    for $spec in $spec:specs    
       let $spec-id := data($spec/@id)
       let $version-id := data($spec/descendant::version/@id)
       let $frequency := index:count-spec-frequency($spec-id, $version-id)
              
       let $status := data($spec/version/@status)       
       let $link := app:link(concat("views/view-spec.xq?id=", $spec-id))
   order by $spec-id
   return   
       (:($spec-id,' ', $frequency, <br/> )      ,:) 
        if (string-length(app:name($spec)) > 30)
            then ()
        else if ( $frequency > 5 or $status = 'International Standard')
            then (<a href="{$link}" class="tag" style="font-size:25px;">{app:name($spec)} </a> , "  ")
        else if ($frequency > 0 or contains($status,"Recommendation"))
            then (<a href="{$link}" class="tag" style="font-size:20px;">{app:name($spec)} </a> , "  ")        
        else (<a href="{$link}" class="tag" style="font-size:12px;">{app:name($spec)} </a> , "  ")
        
};

declare function index:print-sb-links(){            
    for $ssb in sb:get-org()        
        let $ssb-id := $ssb/@id        
        let $frequency := index:count-frequency(spec:get-standardBodies(),$ssb-id)        
        let $link := app:link(concat("views/view-sb.xq?id=", $ssb-id))
        let $ssb-name := app:name($ssb)
        order by $ssb-name
        return
            (: ($ssb-name," ",$frequency),:)
            if ($ssb-id != "SBother") then 
                if ( $frequency > 5)
                then (<a href="{$link}" class="tag" style="font-size:25px;">{$ssb-name} </a>, "  ")
                else if ($frequency > 1)
                then (<a href="{$link}" class="tag" style="font-size:20px;">{$ssb-name} </a>, "  ")
                else (<a href="{$link}" class="tag" style="font-size:12px;">{$ssb-name} </a>, "  ")
            else ()
            
};