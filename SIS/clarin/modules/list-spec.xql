xquery version "3.0";

module namespace lsm="http://clarin.ids-mannheim.de/standards/list-spec";

import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace graph="http://clarin.ids-mannheim.de/standards/graph" at "../modules/graph.xql";

import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace topic="http://clarin.ids-mannheim.de/standards/topic" at "../model/topic.xqm";
import module namespace sb="http://clarin.ids-mannheim.de/standards/standardbody" at "../model/sb.xqm";
import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";
import module namespace center="http://clarin.ids-mannheim.de/standards/center" at "../model/center.xqm";

import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

(: Define functions for the list of standard page
   @author margaretha   
:)

declare variable $lsm:relations := xsd:get-relations();
declare variable $lsm:specs := spec:sort-specs-by-abbr();
declare variable $lsm:spec-sum := spec:sum();

(:declare function lsm:page-by-letter($letter as xs:string, $page as xs:int){
    let $numberOfPages := xs:integer( fn:ceiling( count(spec:get-specs-by-letter($letter)) div 20 ))
    for $i in (1 to $numberOfPages)
    return $i
};:)

(: Create links to move between the list of standard pages :)
declare function lsm:page($sortBy as xs:string, $page as xs:int){
    let $numberOfPages := xs:integer( fn:ceiling($lsm:spec-sum div 20) )
    
    for $i in (1 to $numberOfPages)
    return
        if ($i=$page) then $page
        else if ($i < $page)
        then (<a href="{app:link(concat("views/list-specs.xq?sortBy=", $sortBy,"&amp;page=",$i))}">{$i}</a>," < ") 
        else (" > ",<a href="{app:link(concat("views/list-specs.xq?sortBy=", $sortBy,"&amp;page=",$i))}">{$i}</a>)
};

declare function lsm:letter-filter(){
    let $letters := functx:chars("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
     
    let $links := 
        for $i in 1 to count($letters)
            let $letter := $letters[$i]
        return (<a href="{app:link(concat("views/list-specs.xq?sortBy=name", 
            "&amp;page=",1, "&amp;letter=",$letter))}">{$letter}</a>, " | ")
   return ("| ", $links)
};


(: Define the list header and column size :)
declare function lsm:header($header as xs:string, $sortBy as xs:string, $page as xs:string, $letter as xs:string){
    let $width := 
        if ($header = 'name') then "25%"
        else if ($header = 'topic') then "35%"
        else if ($header = 'org') then "20%"
        else if ($header = 'clarin-centers') then "20%"
        else ()
    let $value := 
        if ($header = 'name') then "Abbreviation/Name"
        else if ($header = 'topic') then "Topic(s)"
        else if ($header = 'org') then "Responsibility"
        else if ($header = 'clarin-centers') then "CLARIN Center(s)"
        else () 
        (:"CLARIN Approved":)
        
    let $lt := if ($letter) then concat("&amp;letter=",$letter) else () 
    
    return    
        if ($header = $sortBy)
        then <th class="header" style="width:{$width}; color:#404040">{$value}</th>
        else <th class="header" style="width:{$width};"><a href="{app:link(concat("views/list-specs.xq?sortBy=", $header,"&amp;page=",$page, $lt))}">{$value}</a></th>
};

(: Define the standard groups per page :)
declare function lsm:group-specs($page as xs:int, $sortBy as xs:string, $letter as xs:string){    
    let $specs := if ($letter) then spec:get-specs-by-letter($letter) else ()
    
    let $specs :=
        if ($sortBy = 'name') then spec:sort-specs-by-abbr($specs,$letter)
        else if ($sortBy = 'topic') then spec:sort-specs-by-topic($specs,$letter)
        else if ($sortBy = 'org') then spec:sort-specs-by-sb($specs,$letter)
        else if ($sortBy = 'clarin-centers') then spec:sort-specs-by-clarin-centers($specs,$letter)
        else ()
            
    let $max := fn:min(($lsm:spec-sum,$page*20)) 
    let $min := if ($page > 1) then (($page -1) * 20) else 1   
    
    return $specs[position() >= $min and position() < $max]
};

(: Create a list of some standards :)
declare function lsm:list-specs($spec-group as item()*, $sortBy as xs:string, $letter as xs:string){
    
    for $spec in $spec-group    
        let $spec-org := data($spec/@standardSettingBody)
        let $sb := sb:get-sb($spec-org)
        let $spec-topics := spec:get-topics($spec)
        let $number-of-spec-topics := count($spec-topics)
        
        let $clarin-centers := spec:get-clarin-centers($spec)
        let $num-of-centers := count($clarin-centers)
        (:let $clarin-approved := spec:get-clarin-approval($spec):)
        
        let $spec-abbr :=$spec/titleStmt/abbr/text()
        order by
            if ($sortBy = 'name') then lower-case($spec-abbr)
            else if ($sortBy = 'topic') then $spec/functx:sort(tokenize(data($spec/@topic),' '))[1]
            else if ($sortBy = 'org') then $spec-org
            else if ($sortBy = 'clarin-centers') then $clarin-centers[1]
            else () (:$clarin-approved[1]:)
    return
        <tr>
          <td style="border-bottom:1px solid #DDDDDD; width:100px; text-align:left; vertical-align:top; padding-right:10px;">
            <a href="{app:link(concat("views/view-spec.xq?id=", $spec/@id ))}" title="{$spec/titleStmt/title/text()}">
              {$spec-abbr}
            </a>
          </td>        
          <td style="border-bottom:1px solid #DDDDDD; width:100px; text-align:left; vertical-align:top;">
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
            else if ($sb[@display="hide"])
            then $sb/titleStmt/abbr/text()
            else <a href="{app:link(concat("views/view-sb.xq?id=", $spec-org))}">{$sb/titleStmt/abbr/text()}</a>             
          }
          </td>
          <td style="border-bottom:1px solid #DDDDDD; width:50px;  text-align:left; vertical-align:top;">
          { for $i in 1 to $num-of-centers
              let $id := $clarin-centers[$i]
              let $c := <a href="{center:get-center($id)/a/@href}">{$id}</a>
            return 
                if ($i < $num-of-centers)
                then ($c, ', ')
                else <a href="{center:get-center($id)/a/@href}">{$id}</a>
          }
          </td>
         <!-- <td style="border-bottom:1px solid #DDDDDD; text-align:center; vertical-align:top;">
          { if ($clarin-approved)
            then 'yes'
            else ($clarin-approved)
          }
          </td> -->
        </tr>
};

(: Create a json object for relation graph among a spec-group :)
declare function lsm:get-spec-json($spec-group){    
    
    let $target-ids :=
        for $spec-relation in $spec-group/descendant-or-self::relation
            let $target := $spec-relation/@target
            let $targetnode := $lsm:specs/descendant-or-self::*[@id=$target]
            let $targetid := $targetnode/ancestor-or-self::spec/@id
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

(: Create a legend for the standard relation graph :)
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
};