xquery version "3.0";

module namespace lsm="http://clarin.ids-mannheim.de/standards/list-spec";

import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace graph="http://clarin.ids-mannheim.de/standards/graph" at "../modules/graph.xql";

import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace topic="http://clarin.ids-mannheim.de/standards/topic" at "../model/topic.xqm";
import module namespace sb="http://clarin.ids-mannheim.de/standards/standardbody" at "../model/sb.xqm";
import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";
import module namespace centre="http://clarin.ids-mannheim.de/standards/centre" at "../model/centre.xqm";

import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

(: Define functions for the list of standard page
   @author margaretha   
:)

declare variable $lsm:relations := xsd:get-relations();
declare variable $lsm:specs := spec:sort-specs-by-abbr();
declare variable $lsm:spec-sum := spec:sum();
declare variable $lsm:pageSize := 20;

(:declare function lsm:page-by-letter($letter as xs:string, $page as xs:int){
    let $numberOfPages := xs:integer( fn:ceiling( count(spec:get-specs-by-letter($letter)) div 20 ))
    for $i in (1 to $numberOfPages)
    return $i
};:)

(: Create links to move between the list of standard pages :)
declare function lsm:page($sortBy as xs:string, $page as xs:int){
    let $numberOfPages := xs:integer( fn:ceiling($lsm:spec-sum div $lsm:pageSize) )
    
    for $i in (1 to $numberOfPages)
    return
        if ($i=$page) then $page
        else if ($i < $page)
        then (<a href="{app:link(concat("views/list-specs.xq?sortBy=", $sortBy,"&amp;page=",$i,"#spec-table"))}">{$i}</a>," < ") 
        else (" > ",<a href="{app:link(concat("views/list-specs.xq?sortBy=", $sortBy,"&amp;page=",$i,"#spec-table"))}">{$i}</a>)
};

declare function lsm:letter-filter(){
    let $letters := functx:chars("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
     
    let $links := 
        for $i in 1 to count($letters)
            let $letter := $letters[$i]
        return (<a href="{app:link(concat("views/list-specs.xq?sortBy=name", 
            "&amp;page=",1, "&amp;letter=",$letter,"#spec-table"))}">{$letter}</a>, " | ")
   return ("| ", $links)
};


(: Define the list header and column size :)
declare function lsm:header($header as xs:string, $sortBy as xs:string, $page as xs:string, $letter as xs:string){
    let $width := 
        if ($header = 'name') then "30%"
        else if ($header = 'topic') then "50%"
        else if ($header = 'org') then "20%"
        (:else if ($header = 'clarin-centres') then "20%":)
        else ()
    let $value := 
        if ($header = 'name') then "Abbreviation/Name"
        else if ($header = 'topic') then "Topic(s)"
        else if ($header = 'org') then "Responsibility"
        (:else if ($header = 'clarin-centres') then "CLARIN Centre(s)":)
        else () 
        (:"CLARIN Approved":)
        
    let $lt := if ($letter) then concat("&amp;letter=",$letter) else () 
    
    return    
        if ($header = $sortBy)
        then <th class="header" style="width:{$width}; color:#404040">{$value}</th>
        else <th class="header" style="width:{$width};"><a href="{app:link(concat("views/list-specs.xq?sortBy=", $header,"&amp;page=",$page, $lt))}">{$value}</a></th>
};                                                                                                              (: can we add "#spec_table" anywhere sensible? :)

(: Define the standard groups per page :)
declare function lsm:group-specs($page as xs:int, $sortBy as xs:string, $letter as xs:string){    
    let $specs := if ($letter) then spec:get-specs-by-letter($letter) else ()
    
    let $specs :=
        if ($sortBy = 'name') then spec:sort-specs-by-abbr($specs,$letter)
        else if ($sortBy = 'topic') then spec:sort-specs-by-topic($specs,$letter)
        else if ($sortBy = 'org') then spec:sort-specs-by-sb($specs,$letter)
        (:else if ($sortBy = 'clarin-centres') then spec:sort-specs-by-clarin-centres($specs,$letter):)
        else ()
            
    let $max := fn:min(($lsm:spec-sum,$page*$lsm:pageSize)) +1
    let $min := if ($page > 1) then (($page -1) * $lsm:pageSize) else 1   
    
    return $specs[position() >= $min and position() < $max]
};

(: Create a list of some standards :)
declare function lsm:list-specs($spec-group as item()*, $sortBy as xs:string, $letter as xs:string){
    
    for $spec in $spec-group    
        let $spec-org := data($spec/@standardSettingBody)
        let $sb := sb:get-sb($spec-org)
        let $spec-topics := spec:get-topics($spec)
        let $number-of-spec-topics := count($spec-topics)
        
    (:  let $clarin-centres := spec:get-clarin-centres($spec)
        let $num-of-centres := count($clarin-centres) :)
        
        (:let $clarin-approved := spec:get-clarin-approval($spec):)
        
        let $spec-abbr :=$spec/titleStmt/abbr/text()
        order by
            if ($sortBy = 'name') then lower-case($spec-abbr)
            else if ($sortBy = 'topic') then $spec/functx:sort(tokenize(data($spec/@topic),' '))[1]
            else if ($sortBy = 'org') then $spec-org
    (:        else if ($sortBy = 'clarin-centres') then $clarin-centres[1]:)
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

       <!--   <td style="border-bottom:1px solid #DDDDDD; width:50px;  text-align:left; vertical-align:top;">
          { for $i in 1 to $num-of-centres
              let $id := $clarin-centres[$i]
              let $c := <a href="{centre:get-centre($id)/a/@href}">{$id}</a>
            return 
                if ($i < $num-of-centres)
                then ($c, ', ')
                else <a href="{centre:get-centre($id)/a/@href}">{$id}</a>
          }
          </td> -->
          
         <!-- <td style="border-bottom:1px solid #DDDDDD; text-align:centre; vertical-align:top;">
          { if ($clarin-approved)
            then 'yes'
            else ($clarin-approved)
          }
          </td> -->
        </tr>
};

(: Create a json object for relation graph among a spec-group :)
declare function lsm:get-spec-json($spec-group,$spec-relations){    
    let $target-specs :=
        for $spec-relation in $spec-relations
               let $target := $spec-relation/@target
               let $targetnode := $lsm:specs[@id=$target]
               return 
                   if ($targetnode) then $targetnode
                   else $lsm:specs[descendant-or-self::node()/@id=$target]
    
    let $reduced-target-specs := 
        for $id in functx:value-except($target-specs/@id,$spec-group/@id)
        return $target-specs[@id=$id]
    
    let $extended-specs := ($spec-group,$reduced-target-specs)    
    
    let $nodes := string-join( for $spec in $extended-specs return graph:create-spec-node($spec) , ",")
    
    let $links := string-join(graph:get-relation($extended-specs, $spec-relations, $lsm:relations),",")
    
    let $json := concat("{", 
        graph:write-json-array("nodes", $nodes) ,",",
        graph:write-json-array("links", $links),
    "}")  
    
    return $json
    
};

(: Create a legend for the standard relation graph :)
declare function lsm:get-legend($spec-relations){

    let $relations := fn:distinct-values(
        for $spec-relation in $spec-relations
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