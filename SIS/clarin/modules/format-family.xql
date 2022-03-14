xquery version "3.1";

module namespace ff = "http://clarin.ids-mannheim.de/standards/format-family";
import module namespace graph="http://clarin.ids-mannheim.de/standards/graph" at "../modules/graph.xql";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";

declare function ff:create-graph-json(){
    let $formats-with-family := $format:formats[./formatFamily]
    let $format-families := fn:distinct-values($formats-with-family/formatFamily/text())
    let $all-formats := ff:gather-formats($formats-with-family,$format-families)
    let $all-ids := $all-formats/@id
    let $target-texts := functx:value-except($format-families,$all-formats/titleStmt/abbr/text())
    let $nodes := string-join( ff:create-format-nodes($all-formats,$target-texts) , ",")
    let $graph-relations := ff:create-graph-relations($formats-with-family, $all-ids, $target-texts)
    let $links := string-join($graph-relations,",")
    
    let $json := concat("{", 
        graph:write-json-array("nodes", $nodes) ,",",
        graph:write-json-array("links", $links),
    "}")  
    
    return $json
};

declare function ff:gather-formats($formats-with-family,$targets){
    let $target-formats :=
        for $ff in $targets
            let $format := format:get-format-by-abbr($ff)
            return 
            if ($format and not($formats-with-family[@id = $format/@id])) 
            then $format else ()
    
        return ($formats-with-family,$target-formats)
};

declare function ff:create-format-nodes($all-formats,$target-texts){
    let $format-nodes := 
        for $format in $all-formats
        return graph:create-format-node($format, fn:true())

    let $target-text-nodes := 
        for $ff in $target-texts
        return graph:create-format-node($ff,fn:false())
        
    return ($format-nodes,$target-text-nodes)
};


declare function ff:create-graph-relations($formats-with-family, $all-ids, $target-texts){
    let $format-size := count($all-ids)
    
    for $ff in $formats-with-family/formatFamily
            let $format := $ff/parent::node()
            let $sourceIndex :=  fn:index-of($all-ids,data($format/@id))-1

            let $target-format := format:get-format-by-abbr($ff/text())
           
            let $targetIndex := 
                if ($target-format) 
                then fn:index-of($all-ids,data($target-format/@id))-1
                else fn:index-of($target-texts, $ff/text()) + $format-size -1
            
            let $relation-type :=
                if ($target-format)
                then $graph:colors[1]
                else $graph:colors[3]
        return graph:create-link($sourceIndex,$targetIndex,$relation-type)
};