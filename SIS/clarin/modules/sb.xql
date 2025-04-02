xquery version "3.0";

module namespace sbm="http://clarin.ids-mannheim.de/standards/sb-module";

import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace graph="http://clarin.ids-mannheim.de/standards/graph" at "../modules/graph.xql";

import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace sb="http://clarin.ids-mannheim.de/standards/standardbody" at "../model/sb.xqm";
import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";

import module namespace functx = "http://www.functx.com" ;

(:  Define standard-body-related functions
    @author margaretha
    @date Dec 2013
:)

(: Get the list of relation types :)
declare variable $sbm:relations := xsd:get-relations();

(: Get the standard body of the given id :)
declare function sbm:get-sb($id as xs:string){
    sb:get-sb($id)
};

(: Get the standard body URL:)
declare function sbm:print-url($sb){    
    let $url := $sb/address[@type="URL"]/text()
    return
        if ($url and not(empty($url)))
        then (
            <div><span class="heading">URL: </span> 
                <a href="{$url}">{$url}</a> 
            </div>)
        else()
};


(: Get a standard body abbreviation :)
declare function sbm:get-sb-abbr($sb,$id,$sb-title){
    let $abbr := $sb/titleStmt/abbr/text()
    let $sb-abbr := 
        if (fn:contains($abbr,"/"))
        then sbm:get-sb-part-links($id,$abbr)
        else ($abbr)    
    return
        if (not($sb-title = $sb-abbr)) then( " (",$sb-abbr,")") else ()
    
};

(: Create links for each part of a standard body abbreviation :)
declare function sbm:get-sb-part-links($id, $abbr){    
    let $sb-links :=
        for $index in functx:index-of-string($id,"-")
            let $id := fn:substring($id,1,$index -1)
            let $link := app:link(concat("views/view-sb.xq?id=",$id))
            return $link     
        
    let $sub-abbr := fn:tokenize($abbr,"/")    
        
    for $i in (1 to fn:count($sub-abbr))
    return 
        if ($i = fn:count($sub-abbr))    
        then <a href="{app:link(concat("views/view-sb.xq?id=",$id))}">{$sub-abbr[$i]}</a>
        else (<a href="{$sb-links[$i]}">{$sub-abbr[$i]}</a>, "/")
};

(: Print the responsible statement of a standard body:)
declare function sbm:get-sb-respStmt($sb){
    for $respStmt in $sb/titleStmt/respStmt 
    return 
        <div>
            <span class="heading">{$respStmt/resp/text()}: </span> {$respStmt/name/text()}
        </div>
};

(: Get the links of all standards published by a standard body :)
declare function sbm:get-specs-by-sb($sb-id as xs:string){    
    let $standards:= 
        for $spec in $spec:specs
        where data($spec/@standardSettingBody) = $sb-id or fn:contains(
            $spec/descendant-or-self::version/titleStmt/respStmt/name/@id, $sb-id)
        return
            <li><a href="{app:link(concat("views/view-spec.xq?id=",$spec/@id))}"
                >{$spec/titleStmt/title/text()}</a></li>
    
    return
        if ($standards) 
        then (<ol>{$standards}</ol>)
        else ()
};

(: Create the json object for creating a relation graph of standard bodies :)
declare function sbm:get-sb-json($id as xs:string){    
    let $sbs := $sb:sbs
    let $sb-ids := fn:insert-before(data($sbs[@id=$id]/relation/@target), 1, $id)
            
    let $nodes := string-join(
        for $id in $sb-ids
            let $sb := $sbs[@id=$id]
            let $link := concat("views/view-sb.xq?id=",$sb/@id)
        return graph:create-node($sb/titleStmt/abbr/text(), $link, 3)
    ,",")
        
    let $links := string-join(
        for $relation in $sbs[@id=$id]/relation
            let $source := fn:index-of($sb-ids,$id) -1
            let $target :=  fn:index-of($sb-ids,$relation/@target) -1
            let $color := graph:get-color($sbm:relations, $relation/@type)            
        return graph:create-link($source, $target, $color)
    ,",")
    
    let $json := concat("{", 
        graph:write-json-array("nodes", $nodes) ,",",
        graph:write-json-array("links", $links),
    "}")  
    
    return $json
}; 

(: Create a list of standard bodies :)
declare function sbm:list-sbs(){
    for $sb in sb:get-org()
        let $sb-id := data($sb/@id)
        let $sb-name := $sb/titleStmt/title/text()
        let $link := <a href="{app:link(concat("views/view-sb.xq?id=", $sb-id))}"> More...</a>
        let $sb-snipet := $sb/info[@type="description"]/p[1]/text()        
        let $standards := sbm:get-specs-by-sb($sb-id)
        order by $sb-name
    return (
        <div>
            <li>
                <span class="list-text pointer" onclick="openEditor('{$sb-id}')">{$sb-name}</span>
            </li>
            <span id="{$sb-id}" style="display:none">   
                <p>{$sb-snipet,$link}</p>
                {if ($standards)
                then (<p>{$sb/titleStmt/abbr/text()} has released the following standard(s):</p>,
                    $standards)
                else ()}
            </span>
        </div>
        )                    
};

(: Generate standard body options :)
declare function sbm:list-sbs-options($selectedSb){    
    for $sb in $sb:sbs
       let $sb-id := data($sb/@id)
       let $sb-abbr := $sb/titleStmt/abbr/text()
       order by $sb-id
    return
       if ($sb-id = $selectedSb)
       then <option selected="true" value="{$selectedSb}">{$sb-abbr}</option>
       else <option value="{$sb-id}">{$sb-abbr}</option>       
};

(: Print a standard body description:)
declare function sbm:print-description($sb){
    <div>{$sb/info[@type="description"]/*}</div>    
};

declare function sbm:create-relation-graph($sb){
    let $color := graph:get-color($sbm:relations, "hasPart")
    return 
    
    if($sb/relation)
    then
      <div id="chart" class="version">
        <div class="version" style="width:140px; float:right; padding:0px">
              <table>
                 <tr>
                     <td colspan="2"><b>Legend:</b></td>                    
                 </tr>
                 <tr>
                     <td><hr style="border:0; color:{$color}; background-color:{$color}; height:2px; width:20px" /></td>
                     <td>hasPart</td>
                 </tr>
               </table>
        </div>
      </div>
    else()

};

(: Print a standard body link:)
declare function sbm:print-sb-link($sb){
     if ($sb = "SBOther")
     then "Other"
     else if (fn:starts-with($sb,"SBISO"))        
     then <a href="{app:link("views/view-sb.xq?id=SBISO")}">
        {sb:get-sb("SBISO")/titleStmt/abbr/text()}</a>
     else
        <a href="{app:link(concat("views/view-sb.xq?id=",$sb))}">
        {sb:get-sb($sb)/titleStmt/abbr/text()}</a>
};

