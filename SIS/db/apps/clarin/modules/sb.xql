xquery version "3.0";

module namespace sbm="http://clarin.ids-mannheim.de/standards/sb-module";

import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace graph="http://clarin.ids-mannheim.de/standards/graph" at "../modules/graph.xql";

import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace sb="http://clarin.ids-mannheim.de/standards/standardbody" at "../model/sb.xqm";
import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";

import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";


declare variable $sbm:relations := xsd:get-relations();

declare function sbm:get-color(){
    graph:get-color($sbm:relations, "hasPart")
};

declare function sbm:get-sb($id as xs:string){
    sb:get-sb($id)
};

declare function sbm:get-specs-by-sb($sb-id as xs:string){    
    for $spec in $spec:specs
    where data($spec/@standardSettingBody) = $sb-id or fn:contains($spec/descendant-or-self::version/titleStmt/respStmt/name/@id, $sb-id)
    return
        <li><a href="{app:link(concat("views/view-spec.xq?id=",$spec/@id))}">{$spec/titleStmt/title/text()}</a></li>
};

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
            <li class="heading2">
                <button style="text-decoration:underline; color: grey; background-color:white; border:0px; padding:0px;" 
                onclick="openEditor('{$sb-id}')">{$sb-name}</button>
            </li>
            <span id="{$sb-id}" style="display:none">   
                <p>{$sb-snipet,$link}</p>
                {if ($standards)
                then (<p>{app:name($sb)} has released the following standard(s):</p>,
                    <ul style="padding:0px; margin-left:25px;">{$standards}</ul>)
                else ()}
            </span>
        </div>
        )                    
};

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

declare function sbm:print-sb-link($sb){
     if ($sb != "SBOther") 
     then <a href="{app:link(concat("views/view-sb.xq?id=",$sb))}">
        {sb:get-sb($sb)/titleStmt/abbr/text()}</a>
     else if (fn:starts-with($sb,"SBISO"))        
     then <a href="{app:link(concat("views/view-sb.xq?id=SBISO"))}">
        {sb:get-sb("SBISO")/titleStmt/abbr/text()}</a>
     else "Other"
};

declare function sbm:print-description($sb){
    $sb/info[@type="description"]/*    
};
