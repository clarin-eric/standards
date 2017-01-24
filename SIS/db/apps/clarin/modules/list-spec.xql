xquery version "3.0";

module namespace lsm="http://clarin.ids-mannheim.de/standards/list-spec";

import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace graph="http://clarin.ids-mannheim.de/standards/graph" at "../modules/graph.xql";

import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace topic="http://clarin.ids-mannheim.de/standards/topic" at "../model/topic.xqm";
import module namespace sb="http://clarin.ids-mannheim.de/standards/standardbody" at "../model/sb.xqm";
import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";

import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

declare variable $lsm:relations := xsd:get-relations();
declare variable $lsm:specs := spec:sort-specs();
declare variable $lsm:spec-sum := spec:sum();

declare function lsm:page($sortBy as xs:string, $page as xs:int){
    let $numberOfPages := xs:integer( fn:ceiling($lsm:spec-sum div 20) )
    
    for $i in (1 to $numberOfPages)
    return
        if ($i=$page) then $page
        else if ($i < $page)
        then (<a href="{app:link(concat("views/list-specs.xq?sortBy=", $sortBy,"&amp;page=",$i))}">{$i}</a>," < ") 
        else (" > ",<a href="{app:link(concat("views/list-specs.xq?sortBy=", $sortBy,"&amp;page=",$i))}">{$i}</a>)
};

declare function lsm:header($header as xs:string, $sortBy as xs:string, $page as xs:string){
    let $width := 
        if ($header = 'name') then "30%"
        else if ($header = 'topic') then "50%"
        else "40%"
    let $value := 
        if ($header = 'name') then "Abbreviation/Name"
        else if ($header = 'topic') then "Topic(s)"
        else "Standard body"        
    return    
        if ($header = $sortBy)
        then <th class="header" style="width:{$width}; color:#404040">{$value}</th>
        else <th class="header" style="width:{$width};"><a href="{app:link(concat("views/list-specs.xq?sortBy=", $header,"&amp;page=",$page))}">{$value}</a></th>
};

declare function lsm:group-specs($page as xs:int){
    let $max := fn:min(($lsm:spec-sum,$page*20)) 
    let $min := if ($page > 1) then (($page -1) * 20) else 1
    return $lsm:specs[position() >= $min and position() < $max]
};

declare function lsm:list-specs($sortBy as xs:string, $spec-group){
    
    for $spec in $spec-group    
        let $spec-org := data($spec/@standardSettingBody)
        let $spec-topics := spec:get-topics($spec)
        let $number-of-spec-topics := count($spec-topics)
        order by
            if ($sortBy = 'name') then lower-case(app:name($spec))
            else if ($sortBy = 'topic') then $spec/@topic
            else $spec-org
    return
        <tr>
          <td style="border-bottom:1px solid #DDDDDD; width:200px; text-align:left; vertical-align:top; padding-right:10px;">
            <a href="{app:link(concat("views/view-spec.xq?id=", $spec/@id ))}" title="{$spec/titleStmt/title/text()}">
              {app:name($spec)}
            </a>
          </td>        
          <td style="border-bottom:1px solid #DDDDDD; width:350px; text-align:left; vertical-align:top;">
          { for $st in 1 to $number-of-spec-topics
              let $topic := topic:get-topic($spec-topics[$st])
            return 
              if (  $number-of-spec-topics > 1 and $st < $number-of-spec-topics)
              then <a href="{app:link(concat('views/view-topic.xq?id=',$spec-topics[$st]))}"> { concat($topic/titleStmt/title/text(),' | ') }</a>
              else <a href="{app:link(concat('views/view-topic.xq?id=',$spec-topics[$st]))}">{ $topic/titleStmt/title/text() }</a>
          }
          </td>
          <td style="border-bottom:1px solid #DDDDDD; vertical-align:top;">
          { if ($spec-org = 'SBOther') then ( "Other" ) 
            else <a href="{app:link(concat("views/view-sb.xq?id=", $spec-org))}">{sb:get-sb($spec-org)/titleStmt/abbr/text()}</a>
          }
          </td>
        </tr>
};

declare function lsm:get-spec-json($spec-group){    
    
    let $target-ids :=
        for $spec-relation in $spec-group/descendant-or-self::relation
            let $target := $spec-relation/@target
            let $targetnode := $lsm:specs/descendant-or-self::*[@id=$target]
            let $targetid := $targetnode/ancestor-or-self::spec/@id[1]
        return $targetid    
            
    let $spec-ids := functx:value-union($spec-group/@id,$target-ids)
    
    let $extended-specs := for $id in $spec-ids return spec:get-spec($id)
    
    let $nodes := string-join( for $spec in $extended-specs return graph:create-spec-node($spec) , ",")        
    let $links := string-join(graph:get-relation($spec-ids,$extended-specs, $spec-group, $lsm:relations),",")
    
    let $json := concat("{", 
        graph:write-json-array("nodes", $nodes) ,",",
        graph:write-json-array("links", $links),
    "}")  
    
    return $json
    
};

declare function lsm:get-legend($spec-group){

    let $relations := fn:distinct-values(
        for $spec-relation in $spec-group/descendant-or-self::relation
        order by $spec-relation/@type
        return data($spec-relation/@type) 
    )
    
    let $sum := count($relations)
    let $median := xs:int(fn:ceiling($sum div 2))
    
    for $sr in 1 to $median 
        let $color := graph:get-color($lsm:relations, $relations[$sr])
        
        let $n := $median + $sr
        let $ncolor := 
            if($sum >= $n) then graph:get-color($lsm:relations, $relations[$n])
            else()
    return
        <tr>
            <td><hr style="border:0; color:{$color}; background-color:{$color}; height:2px; width:20px" /></td>
            <td>{data($relations[$sr])}</td>
            { if($sum >= $n)
              then (<td><hr style="border:0; color:{$ncolor}; background-color:{$ncolor}; height:2px; width:20px" /></td>,
                    <td>{data($relations[$n])}</td>
                    )              
              else <td colspan="2"></td>
            }
        </tr>
        
      
        (:for $spec-relation in $lsm:specs/descendant-or-self::relation
            let $target := data($spec-relation/@target)                    
        return 
            (data($spec-relation/@type), " ", $target, " ",$spec-relation/../titleStmt/title/text(), <br/>)
        (\:if (data($spec-relation/@type) = " isExtensionTo")
            then 
            else ():\):)
            
};