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
    (: collects all values of formatFamily element that are not format abbrs   :)
    let $ff-values := functx:value-except($format-families,$all-formats/titleStmt/abbr/text())
    let $nodes := string-join( ff:create-format-nodes($all-formats,$ff-values) , ",")
    let $graph-relations := ff:create-graph-relations($formats-with-family, $all-ids, $ff-values)
    let $links := string-join($graph-relations,",")
    
    (: Parse format-families.xml   :)
    let $ff-names :=  functx:value-except(ff:parse-node-names(),$ff-values)
    let $ff-nodes := ff:parse-format-family-nodes($ff-names)
    let $ff-relations := ff:parse-format-family-relations(($ff-values,$ff-names), count($all-ids))

    let $ff-nodes-string := string-join($ff-nodes,",")
    (: Join the nodes and links   :)
    let $nodes := concat($nodes,",",$ff-nodes-string)
    let $links := concat($links,",",$ff-relations)
    
    let $json := concat("{", 
        graph:write-json-array("nodes", $nodes) ,",",
        graph:write-json-array("links", $links),
    "}")  
    
    return $json
};

declare function ff:parse-node-names(){
        fn:distinct-values( $format:family//node/@name)
};

declare function ff:parse-format-family-nodes($node-names){
    for $name in $node-names
    return graph:create-format-node($name,fn:false())
};

declare function ff:parse-format-family-relations($graph-nodes,$startIndex){
   let $graph-relations :=
        for $source in $format:family/node
            let $sourceIndex := fn:index-of($graph-nodes,data($source/@name))-1+$startIndex
            
            for $target in $source/node 
                let $targetIndex := fn:index-of($graph-nodes,data($target/@name))-1+$startIndex
                let $relation-type := 
                    if ($target[@rel="encoding"])
                    then $graph:colors[4]
                    else $graph:colors[3]
                return graph:create-link($sourceIndex,$targetIndex,$relation-type)
     let $links := string-join($graph-relations,",")
     return $links
};

(: join all formats that having formatFamiliy elements and all values of the formatFamily 
  elements as a sequence  :)
declare function ff:gather-formats($formats-with-family,$targets){
    let $target-formats :=
        for $ff in $targets
            let $format := format:get-format-by-abbr($ff)
            return 
            if ($format and not($formats-with-family[@id = $format/@id])) 
            then $format else ()
    
        return ($formats-with-family,$target-formats)
};

(: creates a node with a link for each formats and without a link for other formatFamily 
  values :)
declare function ff:create-format-nodes($all-formats,$ff-values){
    let $format-nodes := 
        for $format in $all-formats
        return graph:create-format-node($format, fn:true())

    let $target-text-nodes := 
        for $ff in $ff-values
        return graph:create-format-node($ff,fn:false())
        
    return ($format-nodes,$target-text-nodes)
};

(: 
  Creates a relation in the graph where
  the source-node is the formatFamily value
  the target-node is the format containing a formatFamily element
  the relation label is marked with color
  
  Only two relations are defined
  1. red color where the target node is a format
  2. yellow color where the target node is not a format
  :)
declare function ff:create-graph-relations($formats-with-family, $all-ids, $ff-values){
    let $format-size := count($all-ids)
    
    for $ff in $formats-with-family/formatFamily
            let $format := $ff/parent::node()
            let $targetIndex :=  fn:index-of($all-ids,data($format/@id))-1

            let $source-format := format:get-format-by-abbr($ff/text())
           
            let $sourceIndex := 
                if ($source-format) 
                then fn:index-of($all-ids,data($source-format/@id))-1
                else fn:index-of($ff-values, $ff/text()) + $format-size -1
            
            let $relation-type :=
                if ($source-format)
                then $graph:colors[1]
                else $graph:colors[3]
        return graph:create-link($sourceIndex,$targetIndex,$relation-type)
};