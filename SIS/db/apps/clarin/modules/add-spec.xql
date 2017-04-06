xquery version "3.0";

module namespace asm ="http://clarin.ids-mannheim.de/standards/add-spec-module";

import module namespace data = "http://clarin.ids-mannheim.de/standards/data" at "../model/data.xqm";
import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace sb="http://clarin.ids-mannheim.de/standards/standardbody" at "../model/sb.xqm";
import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";

import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace vsm ="http://clarin.ids-mannheim.de/standards/view-spec" at "../modules/view-spec.xql";
import module namespace sbm ="http://clarin.ids-mannheim.de/standards/sb-module" at "../modules/sb.xql";

import module namespace f = "http://clarin.ids-mannheim.de/standards/module/form" at "../edit/edit-form.xq";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

(: Define functions for adding standards, standard parts and standard versions
   @author margaretha
:)

(: Create a standard part  and store it :)
declare function asm:store-part($spec,$part-id,$part-name,$part-abbr,$part-scope,
    $part-keyword,$part-description){
    
    let $param-names := request:get-parameter-names()    
    let $refs := f:get-param-names($param-names,"pref")
    let $asset := spec:store-asset($refs)
    
    let $part-description := asm:get-description($part-description)
    let $part-id := asm:get-id($part-id)
    
    let $part :=
        <part id="{$part-id}">
            {if ($part-name or $part-abbr) then
                <titleStmt>
                    {if($part-name) then <title>{$part-name}</title> else()}
                    {if($part-abbr) then <abbr>{$part-abbr}</abbr> else()}
                </titleStmt>
                else()}
            {if($part-scope) then <scope>{$part-scope}</scope> else()}            
            {if ($part-keyword)
             then (if (fn:contains($part-keyword,", ")) 
                   then (for $k in fn:tokenize($part-keyword,", ") return <keyword>{$k}</keyword>)
                   else if (fn:contains($part-keyword,","))
                   then (for $k in fn:tokenize($part-keyword,",") return <keyword>{$k}</keyword>)
                   else <keyword>{$part-keyword}</keyword>)
             else ()}
            
            {if($part-description) 
             then util:parse($part-description) 
             else ()}            
            {if ($asset) then <asset>{$asset}</asset> else ()}            
        </part>
    
    let $store :=  spec:store("p",$part,$spec)    
    
    return 
        if (contains(request:get-uri(),"add-spec-part.xq"))
        then response:redirect-to(app:link(concat("views/add-spec-version.xq?id=",
            $spec/@id,"&amp;vparent=",$part-id)))
        else response:redirect-to(app:link(concat(request:get-uri(),"?id=",$spec/@id,
            "&amp;part-title=",$part-name)))
};

(: Create a standard version and store it :)
declare function asm:store-version($param-names,$spec-id,$version-id,$version-date,
    $version-resp,$version-respname,$version-resptype, $version-resporg,
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
    
    let $version-id := asm:get-id($version-id)   
    let $spec := asm:get-spec($spec-id)   
    
    let $content := 
        <content>
            <!--{if ($version-name or $version-abbr or $version-resp) then -->
                <titleStmt>
                    {if($version-name) then <title>{$version-name}</title> else()}
                    {if ($version-abbr) then <abbr internal="no">{$version-abbr}</abbr>
                     else <abbr internal="yes">{asm:get-version-abbr($version-parent,$version-date)}</abbr>}
                    {if ($version-resp) then asm:create-respStmt($spec,$version-resp,$version-resptype,
                        $version-respname,$version-resporg) else()}                   
                </titleStmt>
                <!--else()}-->
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
    
    
    let $parent := 
        if ($version-parent = $spec-id) then spec:store("v",$version,$spec)
        else spec:store("v",$version,$spec/descendant::node()[@id=$version-parent])
       
    return 
        if (session:get-attribute('user') = 'webadmin')
        then response:redirect-to(xs:anyURI(app:link(concat("views/view-spec.xq?id=",
            $spec/@id))))
        else response:redirect-to(xs:anyURI(concat(request:get-uri(),"?id=",$spec/@id,
            "&amp;versionid=",$version-id)))
};

(: Create a responsible statement :)
declare function asm:create-respStmt($spec,$version-resp,$version-resptype,$version-respname,
    $version-resporg){
    (: Generate id   :)
    let $resp-id := f:generateRandomId($spec/descendant-or-self::*/@id)
    let $sbs := <sbs>{sbm:list-sbs-options('')}</sbs>
    let $sb := $sbs/option[text() = $version-resporg]/@value
    return
    
    <respStmt id="{$resp-id}">
        <resp>{$version-resp}</resp>
        {if($version-resptype = "person") then  
            if (fn:contains($version-respname,", ")) 
            then (for $k in fn:tokenize($version-respname,", ") 
                return <name type="{$version-resptype}">{$k}</name>)
            else if (fn:contains($version-respname,","))
            then (for $k in fn:tokenize($version-respname,",") 
                return <name type="{$version-resptype}">{$k}</name>)
            else <name type="{$version-resptype}">{$version-respname}</name>             
            
        else 
            if ($sb) then 
                <name type="org" id="{$sb}">
                {$version-resporg}
                </name>
            else <name type="org">{$version-resporg}</name>
        }
    </respStmt>
};

(: Define a standard version abbreviation :)
declare function asm:get-version-abbr($version-parent,$version-date){
    let $parent := asm:get-spec($version-parent)
    let $parent-abbr := $parent/titleStmt/abbr/text()
    let $version-year := substring($version-date,1,4)
    return 
        if ($parent-abbr) 
        then concat($parent-abbr,"-",$version-year)
        else concat($parent/../titleStmt/abbr/text(),"-",$version-year)
};

(: Define a display value for a field :)
declare function asm:get-display($type,$element,$value){
    if ($type = $element) then $value else 'none'
};

(: Define the width of the abbreviation form :)
declare function asm:get-width(){
   if (session:get-attribute('user')='webadmin')
    then '345px' else '450px'
};

(: Define an spec/part/version id :)
declare function asm:get-id($id){
    if (starts-with($id,"Spec")) then $id 
    else concat("Spec",$id)
};

(: Get a standard given a standard id :)
declare function asm:get-spec($id){
    if (session:get-attribute("user")='webadmin')
    then $spec:specs/descendant-or-self::node()[@id=$id]
    else $spec:reviews/descendant-or-self::node()[@id=$id]
};

(: Get the standard title :)
declare function asm:get-spec-name($spec){
    $spec/titleStmt/title/text()
};

(: Get the id options for parts :)
declare function asm:get-part-options($spec,$version-parent){
    for $part in $spec/part
    let $part-id := data($part/@id)
    return
        if ($version-parent =$part-id)
        then <option value="{$part-id}" selected="true">{$part-id}</option>
        else <option value="{$part-id}">{$part-id}</option>            
};

(: Define the class for an input select field :)
declare function asm:get-select-class($a, $b, $c){
    if(not($a) and ($b or $c)) then "inputSelectError" else "inputSelect"
};

(: Define the class for an input text field :)
declare function asm:get-input-class($a,$b,$c){
    if(not($a) and ($b or $c)) then "inputTextError" else "inputText"
};

(: Validate date and define the class for the date field :)
declare function asm:get-date-class ($submitted,$version-date){
    if ($submitted and not($version-date)) then "inputTextError" 
    else if (f:validate-date($version-date) = fn:false()) then "inputTextError"
    else "inputText"
};

(: Validate url and define the class for the url field :)
declare function asm:get-url-class($version-url){
    if (f:validate-url($version-url)) then "inputText" else "inputTextError"
};

(: Print URL and its edit/add form :)
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

(: Print version relations and the edit forms :)
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
                    {f:list-options(xsd:get-relations(),$version-relation[$i])}                                    
                </select>
                <select id="vtarget{$i}" name="vtarget{$i}" class="{$target-class}" style="width:280px">
                    <option value=""/>
                    {f:list-targets($version-target[$i])}
                </select>                    
                <button type="button" class="button" style="margin-left:3px;" 
                    onclick="addRelation('vr','vrelation','vtarget','vreldesc',{$num},{f:get-options(xsd:get-relations())},
                    {f:get-target-options()})">Add</button>                     
                <textarea id="vreldesc{$i}" name="vreldesc1"class="inputText" placeholder="Describe the relation in one paragraph." 
                    style="width:450px; margin-top:2px; height:50px; resize: none; font-size:11px;">{$version-reldesc[$i]}</textarea>
            </td>
        </tr>
};

(: Print description :)
declare function asm:get-description($description){     
    if ($description) 
    then concat('<info type="description"><p>',fn:replace($description,"\n+\s*","</p><p>"),"</p></info>")
    else ()
};

(: Validate the fields for a standard part :)
declare function asm:validate-part($submitted,$spec,$validate-id,$part-id,$part-name,
    $part-abbr,$part-scope,$part-keyword,$part-description){    
    
    if ($submitted and $validate-id and $part-id and $part-name) 
    then asm:store-part($spec,$part-id,$part-name,$part-abbr,$part-scope,$part-keyword,$part-description)
    else () 
};

(: Validate the fields for a standard version :)
declare function asm:validate-version($submitted,$param-names,$spec-id,$version-id,
    $valid-vid,$version-resp,$version-respname,$version-resptype, $version-resporg,
    $version-date, $version-relation,$version-target,$version-reldesc,$num){
    
    if ($submitted) then 
        (: Validate version id :)
        if (not($version-id) or not ($valid-vid)) then fn:false()        
        
        (: Validate date :)
        else if (not($version-date) or contains(asm:get-date-class("submitted",
            $version-date),"Error")) then fn:false()
        
        (: Validate urls :)
        else if (not (asm:validate-urls($param-names)) ) then fn:false()        
        
        (: Validate required fields by respStmt  :)
        else if (not(asm:validate-respStmt($version-resp,$version-resptype,
            $version-respname,$version-resporg))) then fn:false()
            
        (: Validate required fields by relation :)
        else if (not(asm:validate-relations($version-relation,$version-target,
            $version-reldesc,$num))) then fn:false()        
            
        (: Store version :)
        else asm:store-version($param-names,$spec-id,$version-id,$version-date,
            $version-resp,$version-respname,$version-resptype, $version-resporg,            
            $version-relation,$version-target,$version-reldesc,$num)
        
    else ()
};

(: Validate the obligatory fields in an edit/add relation form :)
declare function asm:validate-relations($version-relation,$version-target,$version-reldesc,$num){
   let $relation-classes := 
        for $i in (1 to $num)    
        return asm:get-select-class($version-relation[$i], $version-target[$i],$version-reldesc[$i])
   let $target-classes :=
        for $i in (1 to $num)    
        return asm:get-select-class($version-target[$i],$version-relation[$i],$version-reldesc[$i])
   return
    if (functx:is-value-in-sequence("inputSelectError", $relation-classes)) then fn:false()
    else if (functx:is-value-in-sequence("inputSelectError", $target-classes)) then fn:false()
    else fn:true()
   
};

(: Validate obligatory fields in a responsible statement edit form :)
declare function asm:validate-respStmt($version-resp,$version-resptype,$version-respname,
    $version-resporg){
    
    let $resp-set := ($version-resp,$version-resptype,$version-respname)
    let $resp-set2 := ($version-resp,$version-resptype,$version-resporg)    
    return
        if ($version-resp or $version-respname or $version-resptype or $version-resporg) then
            if ($version-resptype="person" and functx:is-value-in-sequence("",$resp-set)) then fn:false()
            else if ($version-resptype="org" and functx:is-value-in-sequence("",$resp-set2)) then fn:false()
            else fn:true()
        else fn:true()
        
};

(: Validate urls :)
declare function asm:validate-urls($param-names){
    let $url-classes :=    
        for $i in f:get-param-names($param-names,"vurl")
        let $version-url := request:get-parameter($i,"") 
        return asm:get-url-class($version-url)
    return 
        if (functx:is-value-in-sequence("inputTextError", $url-classes)) then fn:false()
        else fn:true()
};

