xquery version "3.0";
import module namespace data = "http://clarin.ids-mannheim.de/standards/data" at "../model/data.xqm";
import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";

import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace tm ="http://clarin.ids-mannheim.de/standards/topic-module" at "../modules/topic.xql";
import module namespace sbm="http://clarin.ids-mannheim.de/standards/sb-module" at "../modules/sb.xql";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

import module namespace f = "http://clarin.ids-mannheim.de/standards/module/form" at "../edit/edit-form.xq";

import module namespace request = "http://exist-db.org/xquery/request";
declare namespace exist="http://exist.sourceforge.net/NS/exist";

(: Handling the standard editing requests 
   @author margaretha
:)

(: Update abbreviation :)
declare function local:update-abbr($spec-abbr,$val){
    let $values := tokenize($val,"#")
    let $att :=  if ($values[2] = 'internal') then "yes" else "no"
    let $node := 
        <abbr internal="{$att}">
            {$values[1]}
        </abbr>
    return 
        if ($values[1]="") 
        then "empty" 
        else spec:update-spec($spec-abbr,$node)
};

(: Update topic :)
declare function local:update-topic($spec,$val){
    let $u := spec:update-spec($spec/@topic,$val)    
    for $link in tm:print-topic($spec,tokenize(data($spec/@topic),' '),'')
    return $link
};

(: Update standard body :)
declare function local:update-sb($sb,$val){
    let $u := spec:update-spec($sb,$val) 
    return sbm:print-sb-link($sb)
};

(: Update keywords :)
declare function local:update-key($spec,$val){    
    let $keywords := tokenize($val,",")
    let $up := spec:store-keywords($spec,$keywords)
    return fn:string-join($keywords,", ")
};

(: Update asset :)
declare function local:update-reference($spec,$id,$field,$node,$parentnode){
    let $parent := 
        if ($node) then () 
        else ( data:open-access-to-database(),
            update insert <asset/> into $parentnode,
            data:close-access-to-database())
    
    let $login := data:open-access-to-database()
    let $upload := 
        for $file in $refs            
            let $filename := request:get-uploaded-file-name($file)
            let $store := 
                if ($filename) 
                then (xmldb:store($data:doc-path, $filename, request:get-uploaded-file-data($file)),
                      update insert <a href="{$filename}">{$filename}</a> into $node)
                else ()
            return ($filename)
    let $login := data:close-access-to-database()
    let $view := concat("views/view-spec.xq?id=",$id)
    return response:redirect-to(app:link($view)) 
     
};

(: Validate the standard documents to upload :)
declare function local:check-reference($id,$asset-node,$parentnode){
    let $param-names := request:get-parameter-names()
    let $refs := 
        for $param in $param-names
        return if (fn:starts-with($param,"ref")) then $param else ()    
    let $check :=
        for $file in $refs            
        let $filename := request:get-uploaded-file-name($file)
        return if ($filename) then 0 else 1
    let $stored :=
        if (functx:is-value-in-sequence(0,$check))
        then spec:store-asset($refs)
        else fn:false()
    
    let $up := 
        if ($stored) then
            if ($asset-node) then spec:add-into-node($asset-node,$stored)
            else spec:add-into-node($parentnode,<asset>{$stored}</asset>)
        else ()
    
    let $pid := request:get-parameter('pid','')
    let $view := 
        if ($stored)
        then concat("views/view-spec.xq?id=",$id)
        else concat("views/view-spec.xq?display",$pid,"=block&amp;id=",$id,"#ref",$pid,"text")        
        
    return response:redirect-to(app:link($view))
};

(: Check description for standard or standard version :)
declare function local:check-description($id,$spec,$path,$description){
    let $vid := request:get-parameter("vid",'')
    let $eid := if ( $vid !='') then $vid else $id
    
    return
        if ($description) then local:update-description($id,$eid,$spec,$path,$description) 
        else response:redirect-to(app:link(concat("views/view-spec.xq?errorDesc",$eid,"=empty",
            "&amp;id=",$id,"#desctext",$eid)))
};

(: Parse a node :)
declare function local:parse-node($val){
    try { util:parse($val) }
    catch * {concat("Error message: ",$err:description)}
};

(: Update a description
   Validation does not work because it requires targetNamespace in the schema. 
   However, validation may not be necessary since the input for the description 
   are treated as text, except links.
:)
declare function local:update-description($id,$eid,$spec,$path,$description){ 
(:    let $clear := validation:clear-grammar-cache()
    let $val-test := concat('<info xmlns="http://clarin.ids-mannheim.de/standards" type="description">',$description,'</info>'):)
    let $description := replace($description,'&amp;mdash;','&amp;#8212;')
    let $val := concat('<info type="description">',$description,'</info>')
    let $desc-node := local:parse-node($val)
    let $info := 
        if ($eid = $id) then $spec/info[@type="description"] 
        else $spec/descendant-or-self::node()[@id=$eid]/info[@type="description"]        
    
    let $response := 
        if (starts-with($desc-node,"Error message:")) then $desc-node
        else if ($info)
        then spec:update-spec($info,$desc-node)
        else spec:add-version-info($spec/descendant-or-self::node()[@id=$eid]/date,$desc-node)
    
    (:let $response := 
        if (starts-with($desc-node,"Error message:")) then $desc-node
        else if (validation:validate(local:parse-node($val-test),xs:anyURI('/db/apps/clarin/schemas/spec.xsd')))
        then 
            if ($eid = $id) then spec:update-spec($spec/info[@type="description"],$desc-node) 
            else spec:update-spec($spec/descendant-or-self::version[@id=$eid]/info[@type="description"],$desc-node)             
        else "Error message: Validation failed.":)
(:        return validation:validate-report(local:parse-node($val-test),xs:anyURI('/db/apps/clarin/schemas/spec.xsd')):)
    
    let $uri := 
        if (starts-with($response,"Error message:")) 
        then concat("views/view-spec.xq?errorDesc",$eid,"=",$response,"&amp;id=",$id,"#desctext",$eid)
        else concat("views/view-spec.xq?id=",$id,"#desctext",$eid)        
        
    return response:redirect-to( app:link($uri) )
};

(: Check if the version number is not empty and store it :)
declare function local:store-version-number($version,$version-id,$vno,$vno-node,$type){
    if ($vno != '')
    then 
        if ($vno-node)
        then spec:update-spec($vno-node,<versionNumber type="{$type}">{$vno}</versionNumber>)
        else spec:store-version-number($version,$version-id,$type,$vno)
    else ()
};

(: Get the version numbers :)
declare function local:check-version-number($spec,$val,$path,$version-id){
    let $version := $spec//*[@id=$version-id]
    let $vno := tokenize($val,"###")
    let $vnomajor := $version/versionNumber[@type="major"]
    let $vnominor := $version/versionNumber[@type="minor"]
    let $store-vnomajor := local:store-version-number($version,$version-id,$vno[1],$vnomajor,"major")
    let $store-vnominor := local:store-version-number($version,$version-id,$vno[2],$vnominor,"minor")        
    return $val
};

(: Update standard version features :)
declare function local:update-version-features($spec,$val,$node){
    let $version-id := request:get-parameter('pid', '')    
    let $v := util:parse($val)
    let $store := spec:store-version-features($spec,$version-id,$node,$v)
    let $response := 
        for $f in $v/fs/f            
            return concat($f/@name, "++", 
                if ($f/*/@value) 
                then $f/*/data(@value) 
                else functx:trim(fn:string-join($f//text(),' ')))
    return 
        fn:string-join($response, "--")
};

(: Determine to add a new node to a standard or to update an existing node :)
declare function local:update-version-item($spec,$val,$path,$node){
    if ($val = '') then "empty"
    else if ($node and $path="vabbr" and $val!='')
        then local:update-abbr($node,$val)
    else if ($node)
        then spec:update-spec($node/text(),$val)
    else if ($path="vname")
        then spec:add-version-name($spec,$val,request:get-parameter('pid', ''))
    else if ($path="vabbr")
        then spec:add-version-abbr($spec,$val,request:get-parameter('pid', ''))    
    else if ($path="vdate")
        then spec:add-version-date($spec,$val,request:get-parameter('pid', ''))
    else "aha"
};

(: Update a responsible statement of a standard version :)
declare function local:update-version-resp($spec,$val,$path){
    let $values := tokenize($val,"###")
    let $version-id := request:get-parameter('pid', '')
    let $resp-id := substring-after($path, "resp")
    let $resp-node := $spec//*[@id=$version-id]/titleStmt/respStmt[@id=$resp-id]
    
    let $sbs := <sbs>{sbm:list-sbs-options('')}</sbs>
    let $sb := $sbs/option[text() = $values[3]]/@value
    
    let $respStmt := 
        <respStmt id="{$resp-id}">
            <resp>{$values[1]}</resp>
            {if($values[2] = "person") then  
                if (fn:contains($values[3],", ")) 
                then 
                    for $k in fn:tokenize($values[3],", ") 
                    return <name type="{$values[2]}">{$k}</name>
                    
                else if (fn:contains($values[3],","))
                then 
                    for $k in fn:tokenize($values[3],",") 
                    return <name type="{$values[2]}">{$k}</name>
                    
                else <name type="{$values[2]}">{$values[3]}</name>             
                
            else 
                if ($sb) then <name type="org" id="{$sb}">{$values[3]}</name>
                else <name type="org">{$values[3]}</name>
            }
        </respStmt>
          
    return
        if ($resp-node)
        then spec:update-spec($resp-node,$respStmt)
        else spec:add-into-node($spec//*[@id=$version-id]/titleStmt,$respStmt)    
};

(:    let $response := util:parse($values)   
    let $version-id := request:get-parameter('pid', '')
    let $str-length := fn:string-length($path)        
    let $resp-id :=
        if ($task="update") then fn:substring($path,$str-length -5,$str-length)
        else $response/respStmt/@id
    let $val := 
        <respStmt id="{$resp-id}">
        {$response/respStmt/*}
        </respStmt>    
    let $node := 
        if ($task='update') then $spec//*[@id=$version-id]/titleStmt/respStmt[@id=$resp-id]
        else $spec//*[@id=$version-id]/titleStmt    
   return
        if ($task='update')
        then spec:update-spec($node,$val)
        else spec:add-into-node($node,$val)            
       
};

declare function local:check-version-resp($spec,$val,$path,$task){
    (\:let $values := tokenize($val,"###")
    return
        if (functx:is-value-in-sequence("undefined",$values)
        then "empty"
        else ()
:\)
    if (contains($val, ("<respStmt id=","<resp>","</resp>","<name>","</name>" )))
    then local:update-version-resp($spec,$val,$path,$task)
    else "invalid"
};
:)
(: Validate urls and store them :)
declare function local:check-version-url($spec,$val,$path){
    let $version-id := request:get-parameter('pid', '')
    let $node := $spec//*[@id=$version-id]/address
    let $urls :=  if (fn:contains($val,"--")) then tokenize($val,"--") else $val
    let $sequence := 
        for $url in $urls return 
            if (f:validate-url($url)) then $url else 'false'
    return 
        if (functx:is-value-in-sequence('false',$sequence)) 
            then fn:string-join( $sequence,"--" )
        else spec:store-version-url($spec,$version-id,$node,$urls,$val)
};

(: Create version relations and store them :)
declare function local:update-version-relation($spec,$path,$values){    
    let $target := request:get-parameter('pid', '')       
    let $version-id := 
        if(fn:starts-with($path,'vrel')) then fn:substring-after(fn:substring-before($path,'--'),'vrel')
        else fn:substring-after($path,'newvrel')
    
    let $new-relation := 
        <relation target="{$values[2]}" type="{$values[1]}">
            {if ($values[3]) then <info><p>{$values[3]}</p></info> else ()}
        </relation>
    let $update := spec:store-version-relation($spec,$version-id,$target,$new-relation)
    
    let $target-node := spec:get-spec($values[2])
    let $target-link := 
        if ($target-node/@standardSettingBody)
        then concat('view-spec.xq?id=',$target-node/data(@id))
        else concat('view-spec.xq?id=',$target-node/../data(@id),'#',$values[2])    
    let $target-name :=				
         if ($target-node/titleStmt/abbr/text()) then $target-node/titleStmt/abbr/text()          
         else concat( $target-node/ancestor::spec/titleStmt/abbr/text(), "-",
            substring($target-node/date,1,4))
    let $val := fn:insert-before(concat($target-link,'++',$target-name),1,$values)    
       
    return fn:string-join( $val,"--" )
};

(: Validate obligatory fields for version relations :)
declare function local:check-version-relation($spec,$val,$path){
    let $values := fn:tokenize($val,"--")
    let $errors := (
        if (not($values[1]) and ($values[2] or $values[3])) then "errortype" else (),
        if (not($values[2]) and ($values[1] or $values[3])) then "errortarget" else ())
        
    return 
        if ($val eq "----") then "empty"
        else if (count($errors)>0) then fn:string-join( $errors,"--" )
        else local:update-version-relation($spec,$path,$values)        
};

(: Remove a version relation :)
declare function local:remove-version-relation($spec,$target,$path){    
    let $version-id := fn:substring-after(fn:substring-before($path,'--'),'vrel')
    let $node := $spec/descendant-or-self::*[@id=$version-id]/relation[@target=$target]
    return spec:remove-element($node)
};

let $id := request:get-parameter('id', '')
let $path := request:get-parameter('path', '')
let $val := request:get-parameter('value', '')
let $task := request:get-parameter('task', '')
let $spec := spec:get-spec($id)
 
return 
    if ($val and $path ="name")
    then spec:update-spec($spec/titleStmt/title/text(),$val)
    
    else if ($path ="abbr")
    then local:update-abbr($spec/titleStmt/abbr,$val)
    
    else if ($val and $path ="scope")
    then spec:update-spec($spec/scope/text(),$val)
    
    else if ($val and $path ="topic")
    then local:update-topic($spec,$val)
    
    else if($val and $path="sb")
    then local:update-sb($spec/@standardSettingBody,$val)
    
    else if ($val and $path="key")
    then local:update-key($spec,$val)    
    
    else if ($task="upload")
    then local:check-reference($id,$spec/asset,$spec)
    
    else if ($task="uploadversion")
    then local:check-reference($id,$spec//*[@id=request:get-parameter('pid', '')]/asset,$spec//*[@id=request:get-parameter('pid', '')])
    
    else if (fn:starts-with($path,"refv") and $task='remove')    
    then spec:remove-element($spec//*[@id=fn:substring-before(fn:substring-after($path,'refv'),'text')]/asset/a[.=$val])

    else if (fn:starts-with($path,"ref") and $task='remove')
    then spec:remove-element($spec/asset/a[.=$val]) 
        
    else if (fn:starts-with($path,"desc"))
    then local:check-description($id,$spec,$path,$val)      
    
    else if (starts-with($path,"vname"))
    then local:update-version-item($spec,$val,$path,$spec//*[@id=request:get-parameter('pid', '')]/titleStmt/title)
    
    else if (starts-with($path,"vabbr"))
    then local:update-version-item($spec,$val,$path,$spec//*[@id=request:get-parameter('pid', '')]/titleStmt/abbr)
    
    else if ($path="vno" and $val != "###")
    then  local:check-version-number($spec,$val,$path,request:get-parameter('pid', '')) 
    
    else if ($val and $path="vstatus")
    then spec:store-version-status($spec,$val,request:get-parameter('pid', ''))
    
    else if ($path="vdate" and f:validate-date($val))
    then local:update-version-item($spec,$val,$path,$spec//*[@id=request:get-parameter('pid', '')]/date)
    
    else if ($val and fn:starts-with($path,"resp"))
    then local:update-version-resp($spec,$val,$path)
        
    else if ($val and $path ="features")
    then local:update-version-features($spec,$val,$spec//*[@id=request:get-parameter('pid', '')])
    
    else if ($val and fn:starts-with($path,"vurl"))
    then local:check-version-url($spec,$val,$path)
    
    else if (fn:starts-with($path,"vrel") and $task='remove')
    then local:remove-version-relation($spec,$val,$path)
    
    else if (fn:starts-with($path,"vrel") or fn:starts-with($path,"newvrel"))
    then local:check-version-relation($spec,$val,$path)    
    
    else 'empty'
