xquery version "3.0";

module namespace asm ="http://clarin.ids-mannheim.de/standards/add-spec-module";

import module namespace data = "http://clarin.ids-mannheim.de/standards/data" at "../model/data.xqm";
import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";

import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace vsm ="http://clarin.ids-mannheim.de/standards/view-spec" at "../modules/view-spec.xql";

import module namespace f = "http://clarin.ids-mannheim.de/standards/module/form" at "../edit/edit-form.xq";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

declare function asm:store-part($spec,$part-id,$part-name,$part-abbr,$part-scope,$part-keyword,$part-description){     
    let $param-names := request:get-parameter-names()    
    let $refs := f:get-param-names($param-names,"pref")
    let $asset := spec:store-asset($refs)
    
    let $part-description := asm:get-description($part-description)        
    
    let $part :=
        <part id="{$part-id}">
            <titleStmt>
                {if($part-name) then <title>{$part-name}</title> else()}
                {if($part-abbr) then <abbr>{$part-abbr}</abbr> else()}
            </titleStmt>
            {if($part-name) then <scope>{$part-scope}</scope> else()}            
            {if ($part-keyword)
             then (if (fn:contains($part-keyword,", ")) 
                   then (for $k in fn:tokenize($part-keyword,", ") return <keyword>{$k}</keyword>)
                   else if (fn:contains($part-keyword,","))
                   then (for $k in fn:tokenize($part-keyword,",") return <keyword>{$k}</keyword>)
                   else <keyword>{$part-keyword}</keyword>)
             else ()}
            
            {if($part-description) 
             then util:parse($part-description) 
             else <info type="description"></info>}            
            {if ($asset) then <asset>{$asset}</asset> else ()}            
        </part>
    
    let $store :=  spec:store("p",$part,$spec)    
    
    return 
        if (session:get-attribute('user') = 'webadmin')
        then response:redirect-to(xs:anyURI(app:link(concat("views/view-spec.xq?id=",$spec/@id))))
        else response:redirect-to(xs:anyURI(concat(request:get-uri(),"?id=",$spec/@id,"&amp;partid=",$part-id)))
};

declare function asm:store-version($param-names,$spec-id,$version-id,$version-date,
    $version-relation,$version-target,$version-reldesc,$num){
           
    let $version-parent := request:get-parameter("vparent","")
    let $version-name := request:get-parameter("vname","")
    let $version-abbr := request:get-parameter("vabbr","")
    let $version-nomajor := request:get-parameter("vnomajor","")
    let $version-nominor := request:get-parameter("vnominor","")
    let $version-status := request:get-parameter("vstatus","")
    let $version-description := request:get-parameter("vdescription","")
    let $version-features := request:get-parameter("vfeatures","")
    let $version-resp := request:get-parameter("vresp","")
    let $version-description := asm:get-description($version-description)
    
    let $refs := f:get-param-names($param-names,"vref")
    let $asset := spec:store-asset($refs)
    
    let $content := 
        <content>
            <titleStmt>
                {if($version-name) then <title>{$version-name}</title> else()}
                {if($version-abbr) then <abbr>{$version-abbr}</abbr> else()}
                {if($version-resp) then util:parse($version-resp) else()}                   
            </titleStmt>
            {if($version-nomajor) then <versionNumber type="major">{$version-nomajor}</versionNumber> else()}
            {if($version-nominor) then <versionNumber type="minor">{$version-nominor}</versionNumber> else()}
            {if($version-date) then <date>{$version-date}</date> else()}
            {if($version-description) then util:parse($version-description) else()}
            {if ($version-features) then <features>{$version-features}</features> else ()}
            {for $i in f:get-param-names($param-names,"vurl")
             let $version-url := request:get-parameter($i,"") 
             return
                if ($version-url)
                then <address type="URL">{$version-url}</address> 
                else()}
            {for $i in (1 to $num)
             return
                if ($version-relation[$i]!='')
                then
                    <relation type="{$version-relation[$i]}" target="{$version-target[$i]}">
                    {if ($version-reldesc[$i]) then <info type="description"><p>{$version-reldesc[$i]}</p></info> else() }
                    </relation>
                else()
            }
            {if ($asset) then <asset>{$asset}</asset> else ()}      
        </content>
    
    let $version := 
        if ($version-status)
        then
            <version id="{$version-id}" status="{$version-status}">
            {$content/*}    
            </version>
        else 
            <version id="{$version-id}">
            {$content/*}    
            </version>
    
    let $spec := asm:get-spec($spec-id)
    let $parent := 
        if ($version-parent = $spec-id) then spec:store("v",$version,$spec)
        else spec:store("v",$version,$spec/descendant::node()[@id=$version-parent])
       
    return 
        if (session:get-attribute('user') = 'webadmin')
        then response:redirect-to(xs:anyURI(app:link(concat("views/view-spec.xq?id=",$spec/@id))))
        else response:redirect-to(xs:anyURI(concat(request:get-uri(),"?id=",$spec/@id,"&amp;versionid=",$version-id)))
};

declare function asm:get-spec($id){
    if (session:get-attribute("user")='webadmin')
    then $spec:specs[@id=$id]
    else $spec:reviews[@id=$id]
};

declare function asm:get-part-options($spec,$version-parent){
    for $part in $spec/part
    let $part-id := data($part/@id)
    return
        if ($version-parent =$part-id)
        then <option value="{$part-id}" selected="true">{$part-id}</option>
        else <option value="{$part-id}">{$part-id}</option>            
};

declare function asm:get-id-class($submitted, $id){
    if($submitted and not($id)) then "inputTextError" else "inputText"
};

declare function asm:get-select-class($a, $b, $c){
    if(not($a) and ($b or $c)) then "inputSelectError" else "inputSelect"
};

declare function asm:get-input-class($a,$b,$c){
    if(not($a) and ($b or $c)) then "inputTextError" else "inputText"
};

declare function asm:get-date-class ($version-date){
    if (f:validate-date($version-date)) then "inputText" else "inputTextError"
};

declare function asm:get-url-class($version-url){
    if (f:validate-url($version-url)) then "inputText" else "inputTextError"
};

declare function asm:get-urls($param-names){    
    let $version-url := f:get-param-names($param-names,"vurl")
    let $num := fn:max((1,count($version-url)))
    let $version-url := f:get-parameters($param-names,"vurl",$num)
    
    for $i in (1 to $num) 
    return
        <tr>{if ($i = 1) 
             then ( <td valign="top" style="padding-top:10px;">URL Reference:</td> ,  
                    <td> <input id="vurl{$i}" name="vurl{$i}" value="{$version-url[$i]}" type="text" class="{asm:get-url-class($version-url[$i])}" style="width:450px;"/>
                        <button type="button" class="button" style="margin-bottom:3px;" onclick="addElement('vurl','input','text',{$num});">Add</button>
                    </td>
                  )
             else ( <td></td> ,
                     <td> <input id="vurl{$i}" name="vurl{$i}" value="{$version-url[$i]}" type="text" class="{asm:get-url-class($version-url[$i])}" style="width:450px;"/>
                    </td>
                  )
            }
        </tr>
};

declare function asm:get-relations($param-names){   
    let $version-relation := f:get-param-names($param-names,"vrelation")
    let $version-target := f:get-param-names($param-names,"vtarget")    
    let $version-reldesc := f:get-param-names($param-names,"vreldesc")
    let $num := fn:max((1,count($version-relation),count($version-target),count($version-reldesc)))
    
    let $version-relation := f:get-parameters($param-names,"vrelation",$num)
    let $version-target := f:get-parameters($param-names,"vtarget",$num)
    let $version-reldesc := f:get-parameters($param-names,"vreldesc",$num)
    
    for $i in (1 to $num)
    let $relation-class := asm:get-select-class($version-relation[$i], $version-target[$i], $version-reldesc[$i])        
    let $target-class := asm:get-select-class($version-target[$i],$version-relation[$i],$version-reldesc[$i]) 
        
    return            
        <tr id="vr{$i}"> {if ($i=1) then <td valign="top" style="padding-top:10px;">Relation:</td> else <td></td>}
            <td><select id="vrelation{$i}" name="vrelation{$i}" class="{$relation-class}" style="width:173px; margin-right:3px;">
                    <option value=""/>                                        
                    {f:list-options(xsd:get-relation-enumeration(),$version-relation[$i])}                                    
                </select>
                <select id="vtarget{$i}" name="vtarget{$i}" class="{$target-class}" style="width:280px">
                    <option value=""/>
                    {f:list-targets($version-target[$i])}
                </select>                    
                <button type="button" class="button" style="margin-left:3px;" 
                    onclick="addRelation('vr','vrelation','vtarget','vreldesc',{$num},{f:get-options(xsd:get-relation-enumeration())},
                    {f:get-target-options()})">Add</button>                     
                <textarea id="vreldesc{$i}" name="vreldesc1"class="inputText" placeholder="Describe the relation in one paragraph." 
                    style="width:450px; margin-top:2px; height:50px; resize: none; font-size:11px;">{$version-reldesc[$i]}</textarea>
            </td>
        </tr>
};

declare function asm:get-description($description){     
    if ($description) 
    then concat('<info type="description"><p>',fn:replace($description,"\n+\s*","</p><p>"),"</p></info>")
    else ()
};

declare function asm:validate($param-names,$spec-id,$version-id,$version-date,
    $version-relation,$version-target,$version-reldesc,$num){
       
    if (not($version-id)) then fn:false()
    else if (contains(asm:get-date-class($version-date),"Error")) then fn:false()
    else if (functx:is-value-in-sequence("inputTextError", asm:validate-urls($param-names))) then fn:false()    
    else if (functx:is-value-in-sequence("inputSelectError", 
        asm:validate-relations($version-relation,$version-target,$version-reldesc,$num))) then fn:false()
    else if (functx:is-value-in-sequence("inputSelectError", 
        asm:validate-targets($version-relation,$version-target,$version-reldesc,$num))) then fn:false()
    else asm:store-version($param-names,$spec-id,$version-id,$version-date,
        $version-relation,$version-target,$version-reldesc,$num)
};

declare function asm:validate-urls($param-names){
        
    for $i in f:get-param-names($param-names,"vurl")
    let $version-url := request:get-parameter($i,"") 
    return asm:get-url-class($version-url)
    
};

declare function asm:validate-relations($version-relation,$version-target,$version-reldesc,$num){
    for $i in (1 to $num)    
    return asm:get-select-class($version-relation[$i], $version-target[$i],$version-reldesc[$i]) 
};

declare function asm:validate-targets($version-relation,$version-target,$version-reldesc,$num){
    for $i in (1 to $num)    
    return asm:get-select-class($version-target[$i],$version-relation[$i],$version-reldesc[$i])
};
