xquery version "1.0";

import module namespace data = "http://clarin.ids-mannheim.de/standards/data" at "../model/data.xqm";
import module namespace topic="http://clarin.ids-mannheim.de/standards/topic" at "../model/topic.xqm";
import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";

import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace tm ="http://clarin.ids-mannheim.de/standards/topic-module" at "../modules/topic.xql";
import module namespace sbm="http://clarin.ids-mannheim.de/standards/sb-module" at "../modules/sb.xql";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

import module namespace f = "http://clarin.ids-mannheim.de/standards/module/form" at "../edit/edit-form.xq";

import module namespace request = "http://exist-db.org/xquery/request";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes doctype-system=about:legacy-compat";

declare function local:generateRandomId($ids){
    
    let $login := xmldb:login('/db/clarin/data', 'webadmin', 'webadmin')
    let $alpha := functx:chars("ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz")
    let $alpha_length := count($alpha)    
    let $chars := functx:chars("0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz")
    let $char_length := count($chars)
    let $string_length := 6
    let $id := fn:string-join(
        for $i in (1 to $string_length)
           let $index := 
                if ($i=1)
                then util:random($alpha_length)+1
                else util:random($char_length)+1
           let $char :=
                if ($i=1)
                then $alpha[$index]
                else $chars[$index]
           return $char
       , "")
    return 
        if (fn:index-of($ids,$id)>0) then local:generateRandomId($ids)
        else $id
};

(:declare function spec:update-spec($node,$val){
    let $login := data:open-access-to-database()   
    let $up := update replace $node with $val
    let $login := data:close-access-to-database()
    return $val
};

declare function local:remove-element($node){
    let $login := data:open-access-to-database()
    let $up := update delete $node
    let $login := data:close-access-to-database()
    return ''
};:)

declare function local:update-topic($spec,$val){
    let $u := spec:update-spec($spec/@topic,$val)    
    for $link in tm:print-topic($spec,tokenize(data($spec/@topic),' '),'')
    return $link
};

declare function local:update-sb($sb,$val){
    let $u := spec:update-spec($sb,$val) 
    return sbm:print-sb-link($sb)
};

declare function local:update-key($spec,$val){
    let $node := $spec/keyword
    let $keywords := tokenize($val,",")
    let $login := data:open-access-to-database()
    let $d := for $k in $node return update delete $k 
    let $up :=
            for $k in $keywords       
            let $kw := <keyword>{$k}</keyword>            
            return 
                if ($node/text()="") then update replace $node with $kw
                else update insert $kw following $spec/scope
    let $login := data:close-access-to-database()    
    return fn:string-join($keywords,", ")
};

declare function local:update-reference($spec,$id,$field,$node,$parentnode){    
    let $param-names := request:get-parameter-names()
    let $refs := 
        for $param in $param-names
        return if (fn:starts-with($param,$field)) then $param else ()
 
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

declare function local:add-description($spec,$path,$val) {
    let $l := fn:string-length($path)     
    let $newpid := fn:substring($path,$l -5,$l)
    let $parentid := request:get-parameter('pid', '')    
    let $login := data:open-access-to-database()
    let $d := update insert <p id="{$newpid}">{$val}</p> following $spec/info[@type="description"]/p[@id=$parentid]
    let $login := data:close-access-to-database()
    return ""
};

declare function local:update-description($spec,$path,$description){
    (:let $pid := fn:substring($path,5,11)    
    let $u :=
        if ($val)
        then spec:update-spec($spec/info[@type="description"]/p[@id=$pid],<p id="{$pid}">{$val}</p>)
        else spec:remove-element($spec/info[@type="description"]/p[@id=$pid]):)
    let $val :=
        if ($description) 
        then concat('<info type="description"><p>',fn:replace($description,"\n+\s*","</p><p>"),"</p></info>")
        else ()
    
    let $update := 
        if ($val) then spec:update-spec($spec/info[@type="description"],util:parse($val))
        else spec:remove-element($spec/info[@type="description"])

    return util:parse($val)
};

declare function local:add-version-name($spec,$val){
    let $parentid := request:get-parameter('pid', '')
    let $node := $spec//*[@id=$parentid]/titleStmt
    let $login := data:open-access-to-database()    
    let $u :=
        if ($node/abbr)
        then update insert <title>{$val}</title> preceding $node/abbr
        else if ($node/respStmt)
        then update insert <title>{$val}</title> preceding $node/respStmt    
        else update insert <title>{$val}</title> into $node
    let $login := data:close-access-to-database()
    return $val
};

declare function local:add-version-abbr($spec,$val){
    let $parentid := request:get-parameter('pid', '')
    let $node := $spec//*[@id=$parentid]/titleStmt
    let $login := data:open-access-to-database()    
    let $u :=
        if ($node/title)
        then update insert <abbr>{$val}</abbr> following $node/title
        else if ($node/respStmt)
        then update insert <abbr>{$val}</abbr> preceding $node/respStmt    
        else update insert <abbr>{$val}</abbr> into $node
    let $login := data:close-access-to-database()
    return concat(" (",$val,")")
};

declare function local:add-version-number($spec,$val,$type){
    let $parentid := request:get-parameter('pid', '')
    let $node := 
        if ($type="minor" and $spec//*[@id=$parentid]/versionNumber)
        then $spec//*[@id=$parentid]/versionNumber
        else $spec//*[@id=$parentid]/titleStmt
    let $login := data:open-access-to-database()
    let $up := update insert <versionNumber type="{$type}">{$val}</versionNumber> following $node
    let $login := data:close-access-to-database()
    return $val
};

declare function local:add-version-date($spec,$val){
    let $parentid := request:get-parameter('pid', '')
    let $node := $spec//*[@id=$parentid]
    let $login := data:open-access-to-database()    
    let $u :=
        if ($node/versionNumber)
        then update insert <date>{$val}</date> following $node/versionNumber[count($node/versionNumber)]        
        else update insert <date>{$val}</date> following $node/titleStmt
    let $login := data:close-access-to-database()
    return $val
};

declare function local:update-version-features($spec,$val,$node){
    let $version-id := request:get-parameter('pid', '')    
    let $v := util:parse($val)
    let $login := data:open-access-to-database()    
    let $n := 
        if ($node/features)
        then update replace $node/features with <features>{$v}</features>
        else if ($node/info[@type='description'])
        then update insert <features>{$v}</features> following $spec//*[@id=$version-id]/info[@type='description']
        else if ($node/date)
        then update insert <features>{$v}</features> following $node/date
        else if ($node/versionNumber)
        then update insert <features>{$v}</features> following $node/versionNumber
        else update insert <features>{$v}</features> following $node/titleStmt
    let $login := data:close-access-to-database()
    let $response := 
        for $f in $v/fs/f            
            return concat($f/@name, "++", if ($f/*/@value) then $f/*/data(@value) else functx:trim(fn:string-join($f//text(),' ')))
    return 
        fn:string-join($response, "--")
};

declare function local:update-version-item($spec,$val,$path,$node){    
    if ($node and $path="vabbr" and $val!='')
    then concat(" (",spec:update-spec($node/text(),$val),")")    
    else if ($node)
    then spec:update-spec($node/text(),$val)
    else if ($path="vname")
    then local:add-version-name($spec,$val)
    else if ($path="vabbr")
    then local:add-version-abbr($spec,$val)
    else if ($path="vnomajor")
    then local:add-version-number($spec,$val,"major")
    else if ($path="vnominor")
    then local:add-version-number($spec,$val,"minor")
    else if ($path="vdate")
    then local:add-version-date($spec,$val)
    else "aha"
};

declare function local:update-version-status($spec,$val){
    let $parentid := request:get-parameter('pid', '')
    let $node := $spec//*[@id=$parentid]/@status
    let $login := data:open-access-to-database()    
    let $up := 
        if ($node) then update value $node with $val
        else update replace $spec//*[@id=$parentid] 
             with <version id="{$parentid}" status="{$val}">{$spec//*[@id=$parentid]//*}</version>
    let $login := data:close-access-to-database()
    return $val
};

declare function local:update-version-resp($spec,$values,$path,$task){

    let $response := util:parse($values)
   (:     for $v in (1 to count($values)) return 
            if ($v =1) then concat("resp",$values[$v])
            else if ($v=3) then concat("name",$values[$v])
            else if ($v=4 and $values[4]) then $values[$v]
            else ()
    let $response := fn:string-join($response,"#") $response/@id :)
    
    let $version-id := request:get-parameter('pid', '')
    let $str-length := fn:string-length($path)
    let $ids := $spec//*/respStmt/@id
    
    let $resp-id :=
        if ($task="update") then fn:substring($path,$str-length -5,$str-length)
        else $response/respStmt/@id
        
    (: local:generateRandomId($ids)
    let $up :=
        <respStmt id="{$resp-id}">
            <resp>{$values[1]}</resp>
            { if (fn:contains($values[3],", ")) (:comma with space:)
              then
                for $name in fn:tokenize($values[3],", ")
                return <name type="{$values[2]}" id="{$values[4]}">{$name}</name> 
              else if (fn:contains($values[3],",")) (:comma:)
              then
                for $name in fn:tokenize($values[3],",")
                return <name type="{$values[2]}" id="{$values[4]}">{$name}</name>
              else <name type="{$values[2]}" id="{$values[4]}">{$values[3]}</name>
            }
        </respStmt>
        :)
   
    let $up := 
        <respStmt id="{$resp-id}">
        {$response/respStmt/*}
        </respStmt>
    
    let $node := 
        if ($task='update') then $spec//*[@id=$version-id]/titleStmt/respStmt[@id=$resp-id]
        else $spec//*[@id=$version-id]/titleStmt
    let $login := data:open-access-to-database()
    let $store := 
        if ($task='update')
        then update replace $node with $up
        else update insert $up into $node
            
    let $login := data:close-access-to-database()
    
    return $up
       (: if ($task="update") then $response 
        else concat($resp-id,"***",$response):)
};

(:declare function local:check-version-resp($spec,$val,$path,$task){
    
    let $values := fn:tokenize($val,"#")    
    let $error :=
        for $item in fn:index-of($values,'') return
            if ($item=1) then concat("error",$path)
            else if ($item=2) then concat("error", $path,"type")
            else concat("error", $path,"name")            
    let $error := if (count($error) >0) then fn:string-join($error,"#") else ()
    
    return 
        if ($error) then $error
        else local:update-version-resp($spec,$path,$values,$task)        
};:)

declare function local:update-version-url($spec,$version-id,$node,$urls,$val){
    let $login := data:open-access-to-database()
    let $del := for $k in $node return update delete $k 
    let $up :=
        for $k in fn:reverse($urls)
        let $u := <address type="URL">{$k}</address>      
        return 
            if ($spec//*[@id=$version-id]/features) 
                then update insert $u following $spec//*[@id=$version-id]/features
            else 
                update insert $u following $spec//*[@id=$version-id]/info[@type='description']
    let $login := data:close-access-to-database()
    return $val
};

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
        else local:update-version-url($spec,$version-id,$node,$urls,$val)
};

declare function local:update-version-relation($spec,$path,$values){    
        
    let $target-node := spec:get-spec($values[2])
    let $target-link := 
        if ($target-node/@standardSettingBody)
        then concat('view-spec.xq?id=',$target-node/data(@id))
        else concat('view-spec.xq?id=',$target-node/../data(@id),'#',$values[2])
    let $n := $target-node/ancestor-or-self::node()/titleStmt/title/text()
    let $nn := count($n)
    let $vn := $target-node/versionNumber
    let $target-name :=				
         if ($vn) 
         then (concat($n[$nn],' ',$vn[count($vn)]/text())) 
         else $n[$nn]
       
    let $target := request:get-parameter('pid', '')       
    let $version-id := 
        if(fn:starts-with($path,'vrel')) then fn:substring-after(fn:substring-before($path,'--'),'vrel')
        else fn:substring-after($path,'newvrel')
    let $node := $spec//*[@id=$version-id]/relation[@target=$target]
    let $new-relation := 
        <relation target="{$values[2]}" type="{$values[1]}">
            <info><p>{$values[3]}</p></info>
        </relation>    
    
    let $login := data:open-access-to-database()    
    let $up :=
        if ($node) then update replace $node with $new-relation
        else 
            if ($spec//*[@id=$version-id]/asset)
            then update insert $new-relation preceding $spec//*[@id=$version-id]/asset
            else update insert $new-relation into $spec//*[@id=$version-id]
    let $login := data:close-access-to-database()
    let $val := fn:insert-before(concat($target-link,'++',$target-name),1,$values)
       
    return fn:string-join( $val,"--" )
};

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

declare function local:remove-version-relation($spec,$target,$path){    
    let $version-id := fn:substring-after(fn:substring-before($path,'--'),'vrel')
    let $node := $spec//*[@id=$version-id]/relation[@target=$target]
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
    then spec:update-spec($spec/titleStmt/abbr/text(),$val)
    
    else if ($path ="scope")
    then spec:update-spec($spec/scope/text(),$val)
    
    else if ($val and $path ="topic")
    then local:update-topic($spec,$val)
    
    else if($val and $path="sb")
    then local:update-sb($spec/@standardSettingBody,$val)
    
    else if ($path="key")
    then local:update-key($spec,$val)    
    
    else if ($task="upload")
    then local:update-reference($spec,$id,"ref",$spec/asset,$spec)
    
    else if ($task="uploadversion")
    then local:update-reference($spec,$id,"refv",$spec//*[@id=request:get-parameter('pid', '')]/asset,$spec//*[@id=request:get-parameter('pid', '')])    
    
    else if (fn:starts-with($path,"refv") and $task='remove')    
    then spec:remove-element($spec//*[@id=fn:substring-before(fn:substring-after($path,'refv'),'text')]/asset/a[.=$val])

    else if (fn:starts-with($path,"ref") and $task='remove')
    then spec:remove-element($spec/asset/a[.=$val]) 
        
    else if (fn:starts-with($path,"desc"))
    then local:update-description($spec,$path,$val)
    
    (:else if ($val and fn:starts-with($path,"adddesc"))
    then local:add-description($spec,$path,$val):)
    
    else if ($path="vname")
    then local:update-version-item($spec,$val,$path,$spec//*[@id=request:get-parameter('pid', '')]/titleStmt/title)
    
    else if ($path="vabbr")
    then local:update-version-item($spec,$val,$path,$spec//*[@id=request:get-parameter('pid', '')]/titleStmt/abbr)
    
    else if ($path="vnomajor")
    then local:update-version-item($spec,$val,$path,$spec//*[@id=request:get-parameter('pid', '')]/versionNumber[@type="major"])
    
    else if ($path="vnominor")
    then local:update-version-item($spec,$val,$path,$spec//*[@id=request:get-parameter('pid', '')]/versionNumber[@type="minor"])
    
    else if ($path="vstatus")
    then local:update-version-status($spec,$val)
    
    else if ($path="vdate" and f:validate-date($val))
    then local:update-version-item($spec,$val,$path,$spec//*[@id=request:get-parameter('pid', '')]/date)
    
    else if (fn:starts-with($path,"resp"))
    then local:update-version-resp($spec,$val,$path,'update')
    
    else if (fn:starts-with($path,"newresp"))
    then local:update-version-resp($spec,$val,$path,'add')
    
    else if (fn:starts-with($path,"features"))
    then local:update-version-features($spec,$val,$spec//*[@id=request:get-parameter('pid', '')])
    
    else if (fn:starts-with($path,"vurl"))
    then local:check-version-url($spec,$val,$path)
    
    else if (fn:starts-with($path,"vrel") and $task='remove')
    then local:remove-version-relation($spec,$val,$path)
    
    else if (fn:starts-with($path,"vrel") and $task='')
    then local:check-version-relation($spec,$val,$path)
    
    else if (fn:starts-with($path,"newvrel"))
    then local:check-version-relation($spec,$val,$path)
    
    else 'empty'
