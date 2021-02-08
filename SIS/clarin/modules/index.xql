xquery version "3.0";

module namespace index="http://clarin.ids-mannheim.de/standards/index";
import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace sb="http://clarin.ids-mannheim.de/standards/standardbody" at "../model/sb.xqm";

(: Count the frequency of appearance of an id in a list or sequence :)
declare function index:count-frequency($list as item()*, $id as xs:string){
    count (for $item in $list[. = ($id)] return $item)
};

(: Count the frequency of standard references :)
declare function index:count-spec-frequency($spec-id as xs:string, $version-id as item()*){
    let $targets := spec:get-targets()
    
    (: Count how many times a standard are referred by other standards or versions :)    
    let $references-of-spec-id := index:count-frequency($targets, $spec-id)
    
    (: Count how many times the standard versions are referred by other standards or versions :)
    let $references-of-spec-versions := 
        sum( for $id in $version-id return index:count-frequency($targets,$id) )
        
    return $references-of-spec-id + $references-of-spec-versions    
};

(: Generate links of the standards for the tag cloud. The links are weighted based on frequency 
   of standard references and the standard's status. The weights determine the font-size of the 
   standard tags. 
:)   
declare function index:print-spec-links() {
    for $spec in $spec:specs    
       let $spec-id := data($spec/@id)
       let $spec-abbr := $spec/titleStmt/abbr/text()
       let $version-id := data($spec/descendant::version/@id)
       let $frequency := index:count-spec-frequency($spec-id, $version-id)
       
       let $status := data($spec/version/@status)       
       let $link := app:link(concat("views/view-spec.xq?id=", $spec-id))
   order by $spec-id
   return 
        if ( $frequency > 5 or $status = 'International Standard')
            then (<a href="{$link}" class="tag" style="font-size:25px;">{$spec-abbr} </a> , "  ")
        else if ($frequency > 0 or contains($status,"Recommendation"))
            then (<a href="{$link}" class="tag" style="font-size:20px;">{$spec-abbr} </a> , "  ")        
        else (<a href="{$link}" class="tag" style="font-size:12px;">{$spec-abbr} </a> , "  ")
        
};


(: Generate links of the standard bodies for the tag cloud. The links are weighted based on
   the number of standards a standard body have published. The weights determine the font-size
   of the standard body tags.
:)
declare function index:print-sb-links(){            
    for $ssb in sb:get-org()        
        let $ssb-id := $ssb/@id       
        
        (: Count how many standards belongs to a standard body :)
        let $frequency := index:count-frequency(spec:get-standardBodies(),$ssb-id)        
        
        let $link := app:link(concat("views/view-sb.xq?id=", $ssb-id))
        let $ssb-name := $ssb/titleStmt/abbr/text()
        order by $ssb-name
        return            
            if ($ssb-id != "SBother") then 
                if ( $frequency > 5)
                then (<a href="{$link}" class="tag" style="font-size:25px;">{$ssb-name} </a>, "  ")
                else if ($frequency > 1)
                then (<a href="{$link}" class="tag" style="font-size:20px;">{$ssb-name} </a>, "  ")
                else (<a href="{$link}" class="tag" style="font-size:12px;">{$ssb-name} </a>, "  ")
            else ()
            
};