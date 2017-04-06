xquery version "3.0";

module namespace graph="http://clarin.ids-mannheim.de/standards/graph";
import module namespace data="http://clarin.ids-mannheim.de/standards/data" at "../model/data.xqm";
import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

(: Functions for relation graphs
   @author margaretha
   @date Dec 2013
:)

(: Define colors for the relation types :)
declare variable $graph:colors := ('#FF0000','#FF8A00','#F5DE82','#0DE046','#34995E','#C0C0C0','#00C2FF','#0066FF','#8F00FF','#FF008A',
        '#F2A2B0','#CCB647','#98C5AB','#B39F73','#62587C','#4D4E24','#A37B5F','#569AA3','#D9AAF0','#CCFF00', 
        '#FC62EA','#47CCF5','#00FFFF','#000','#5F8FE8','#A2D6F2','#D4941E');

(: Create a json object key-value pair :)
declare function graph:write-json-pair($key, $value){
    if (functx:is-a-number($value))
        then concat('"', $key, '" : ', $value)
    else
        concat('"', $key, '" : "', $value,'"')
};

(: Create a json array :)
declare function graph:write-json-array($key, $value){
    concat('"', $key, '":[', $value,']')
};

(: Create a graph node containing information about the node name, 
   the node link and the node size :)
declare function graph:create-node($node-name, $node-link, $node-size){
    concat("{", 
            graph:write-json-pair("name", $node-name) ,",",
            graph:write-json-pair("reflink", app:link($node-link)) ,",",
            graph:write-json-pair("size", $node-size),
        "}")
};

(: Create a graph link containing information about the link label, 
   the source node and the target node which determine the direction 
   of the link :)
declare function graph:create-link($source, $target, $label){
    concat("{", 
            graph:write-json-pair("source", $source) ,",",
            graph:write-json-pair("target", $target) ,",",
            graph:write-json-pair("label", $label),
        "}")
};

(: Create a graph node for the given spec or spec version :)
declare function graph:create-spec-node($node){    
    let $node-title := $node/titleStmt/title/text()
    let $node-name := $node/titleStmt/abbr/text() 
        (:if ($node/titleStmt/abbr/text())
        then $node/titleStmt/abbr/text()
        else concat($node/ancestor::spec/titleStmt/abbr/text(),
                "-",substring($node/date,1,4)):)
        
    let $node-link := 
        if ($node/@standardSettingBody)
        then concat("views/view-spec.xq?id=",$node/data(@id))
        else concat("views/view-spec.xq?id=",$node/ancestor::spec/data(@id),'#',data($node/@id))
    
    let $node-size := if ($node/@standardSettingBody) then 4 else 3 
    
    return graph:create-node($node-name, $node-link, $node-size) 
    
};

(: Get the link colors for the relation types :)
declare function graph:get-color($relations, $relation){
    $graph:colors[fn:index-of($relations,$relation)]
};

(: Get all the relation links of a group of spec (e.g. for creating a relation 
   graph of 20 specs) :)
declare function graph:get-relation($spec-ids,$specs,$spec-group,$relations){                    
    
    let $results :=    
        for $spec-relation in $spec-group/descendant-or-self::relation
            let $spec-id := $spec-relation/ancestor-or-self::spec/@id[1]
            let $spec-index := fn:index-of($spec-ids,data($spec-id))-1
            
            let $target := $spec-relation/@target
            let $targetnode := $specs/descendant-or-self::*[@id=$target]
            let $targetid := $targetnode/ancestor-or-self::spec/@id[1]
            
            let $target-index := 
                if ($targetid)
                then fn:index-of($spec-ids,data($targetid))-1
                else ()
                        
            let $relation-type := $graph:colors[fn:index-of($relations,data($spec-relation/@type))]
            order by $spec-relation/@type
            return ( 
                if ($targetnode and not($spec-index = $target-index))
                then graph:create-link($spec-index, $target-index, $relation-type)
                else ()
                )
    return fn:distinct-values($results)
    
};

(: Create links for the version relations of the given spec :)
declare function graph:create-version-link($spec, $ids, $relations){
    for $version in $spec/descendant-or-self::version        
        let $version-index := fn:index-of($ids,data($version/@id))-1  
           
        for $rel in $version/relation
            let $target-index := fn:index-of($ids,data($rel/@target))-1            
            let $relation-type := graph:get-color($relations, data($rel/@type))
            return graph:create-link($version-index, $target-index, $relation-type)
};
