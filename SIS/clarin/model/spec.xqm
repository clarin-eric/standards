xquery version "3.0";

module namespace spec="http://clarin.ids-mannheim.de/standards/specification";

import module namespace data = "http://clarin.ids-mannheim.de/standards/data" at "data.xqm";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

(: Define methods to access the standard data or store new standard data
   @author margaretha
:)

(: Select all standards that are not hidden :)
declare variable $spec:specs := collection("/db/apps/clarin/data/specifications")/spec[not(data(@display)='hide')];
(: Select all standards submitted by the user :)
declare variable $spec:reviews := collection("/db/apps/clarin/data/review")/spec;

(: Create an ordered sequence of standards by standard abbreviation :)
declare function spec:sort-specs-by-abbr($specs,$letter){
    let $specs := if($letter) then $specs else $spec:specs
    return
        for $spec in $specs
        order by $spec/titleStmt/abbr/text()
        return $spec
};

declare function spec:sort-specs-by-abbr(){
    spec:sort-specs-by-abbr("","")
};

declare function spec:sort-specs-by-topic($specs,$letter){
    let $specs := if($letter) then $specs else $spec:specs
    return
        for $spec in $specs               
        order by $spec/functx:sort(tokenize(data($spec/@topic),' '))[1]
        return $spec
};

declare function spec:sort-specs-by-sb($specs,$letter){
    let $specs := if($letter) then $specs else $spec:specs
    return
        for $spec in $specs
        order by $spec/@standardSettingBody
        return $spec
};

declare function spec:sort-specs-by-clarin-centres($specs,$letter){
    let $specs := if($letter) then $specs else $spec:specs
    return
        for $spec in $specs    
        order by $spec/functx:sort(tokenize(data(descendant-or-self::node()/@usedInCLARINCentre),' '))[1]
        return $spec
};

(:declare function spec:sort-specs-by-clarin-approval(){
    for $spec in $spec:specs
    let $p := $spec/descendant-or-self::version[@CLARINapproved='yes']
    order by $p[1]
    return $spec
};
:)

declare function spec:get-specs-by-letter($letter){
    for $spec in $spec:specs[fn:starts-with(upper-case(titleStmt/abbr/text()),$letter)]
    order by $spec/titleStmt/abbr
    return $spec
};


(: Get the spec/part/version node of the given id :)
declare function spec:get-spec($id as xs:string){
    $spec:specs/descendant-or-self::node()[@id=$id]
};

(: Count the number of standards in the collection:)
declare function spec:sum(){
    count($spec:specs)
};

(: Get all the target of standard relations :)
declare function spec:get-targets(){   
    for $spec in $spec:specs         
    return $spec/descendant-or-self::node()/relation/data(@target)
};

(: Get all the standard bodies:)
declare function spec:get-standardBodies(){
    $spec:specs/data(@standardSettingBody)
};

(: Get the topic of a standard :)
declare function spec:get-topics($spec){
    for $t in tokenize(data($spec/@topic),' ')
    order by $t
    return $t
};

declare function spec:get-clarin-centres($spec){    
    for $c in tokenize(data($spec/descendant-or-self::*/@usedInCLARINCentre),' ') 
    order by $c
    return $c   
};

declare function spec:get-clarin-approval($spec){
    $spec/descendant-or-self::version[@CLARINapproved='yes']
};

(: Update a node in a standard :)
declare function spec:update-spec($node,$val){
    let $login := data:open-access-to-database()   
    let $up := update replace $node with $val
    let $login := data:close-access-to-database()
    return $val
};

(: Remove a node in a standard :)
declare function spec:remove-element($node){
    let $login := data:open-access-to-database()
    let $up := update delete $node
    let $login := data:close-access-to-database()
    return ''
};

(: Add a node in a standard :)
declare function spec:add-into-node($node,$val){
    let $login := data:open-access-to-database()
    let $store := update insert $val into $node            
    let $login := data:close-access-to-database()
    return $val    
};

(: Add a version name to a version standard :)
declare function spec:add-version-name($spec,$val,$parentid){
    let $node := $spec//*[@id=$parentid]/titleStmt
    let $login := data:open-access-to-database()    
    let $u :=
        if ($node/*)
        then update insert <title>{$val}</title> preceding $node/*[1]            
        else update insert <title>{$val}</title> into $node
    let $login := data:close-access-to-database()
    return $val
};

(: Add a version abbreviation to a version standard :)
declare function spec:add-version-abbr($spec,$val,$parentid){    
    let $node := $spec//*[@id=$parentid]/titleStmt
    let $login := data:open-access-to-database()    
    let $u :=
        if ($node/title)
        then update insert <abbr>{$val}</abbr> following $node/title
        else if ($node/respStmt)
        then update insert <abbr>{$val}</abbr> preceding $node/respStmt    
        else update insert <abbr>{$val}</abbr> into $node
    let $login := data:close-access-to-database()
    return $val
};

(: Add a version date to a version standard :)
declare function spec:add-version-date($spec,$val,$parentid){
    let $node := $spec//*[@id=$parentid]
    let $login := data:open-access-to-database()    
    let $u :=
        if ($node/versionNumber)
        then update insert <date>{$val}</date> following $node/versionNumber[count($node/versionNumber)]
        else if ($node/titleStmt)        
        then update insert <date>{$val}</date> following $node/titleStmt
        else update insert <date>{$val}</date> into $node
    let $login := data:close-access-to-database()
    return $val
};

(: Add an info node :)
declare function spec:add-version-info($node,$val){
    let $login := data:open-access-to-database()
    let $store := update insert $val following $node
    let $login := data:close-access-to-database()
    return $val    

};

(: Store a standard part or version :)
declare function spec:store($prefix,$node,$spec){
    let $login := data:open-access-to-database()
    let $c := count($spec/info)
    let $store := 
        if ($prefix="p") then 
            if ($spec/part) then update insert $node following $spec/part[last()]
            else update insert $node following $spec/info[$c]
        else if ($prefix="v") then
            if ($spec/version) then update insert $node following $spec/version[last()]
            else 
                if ($spec/asset)
                then update insert $node preceding $spec/asset
                else update insert $node into $spec            
        else()
    let $login := data:close-access-to-database()
    return ""
};

(: Store a new standard :)
declare function spec:store-new-spec($file,$spec,$path){
    let $login := data:open-access-to-database()
    let $store := xmldb:store($path,$file,$spec) 
    let $login := data:close-access-to-database()
    return ""
};

(: Store standard documents and create reference links to them :)
declare function spec:store-asset($refs){        
    let $login := data:open-access-to-doc()
    let $asset :=
        for $file in $refs
        let $filename := request:get-uploaded-file-name($file)
        let $store := 
            if ($filename) then xmldb:store($data:doc-path, $filename, request:get-uploaded-file-data($file)) 
            else ()
        return
            if ($filename) then <a href="{$filename}">{$filename}</a> 
            else ()
        
    let $login := data:close-access-to-doc()
    return $asset
};

(: Store standard keywords :)
declare function spec:store-keywords($spec,$keywords){
    let $kw := 
        for $k in $keywords
        return <keyword>{$k}</keyword>            
    
    let $login := data:open-access-to-database()
    let $d := update delete $spec/keyword 
    let $up := update insert $kw following $spec/scope
    let $login := data:close-access-to-database()  
    return ''
};

(: Store version features :)
declare function spec:store-version-features($spec,$version-id,$node,$v){
    let $login := data:open-access-to-database()    
    let $n := 
        if ($node/features)
        then update replace $node/features with <features>{$v}</features>
        else if ($node/info[@type='description'])
        then update insert <features>{$v}</features> following $spec//*[@id=$version-id]/info[@type='description']
        else update insert <features>{$v}</features> following $node/date       
        
    let $login := data:close-access-to-database()
    return ""
};

declare function spec:store-version-number($version,$version-id,$type,$val){
    let $node := 
        if ($type="minor" and $version/versionNumber)
        then $version/versionNumber
        else $version/titleStmt
    let $login := data:open-access-to-database()
    let $up := update insert <versionNumber type="{$type}">{$val}</versionNumber> following $node
    let $login := data:close-access-to-database()
    return ""
};

declare function spec:store-version-relation($spec,$version-id,$target,$new-relation){
    let $login := data:open-access-to-database()
    let $node := $spec/descendant-or-self::*[@id=$version-id]/relation[@target=$target]
    let $up :=
        if ($node) then update replace $node with $new-relation
        else 
            if ($spec/descendant-or-self::*[@id=$version-id]/asset)
            then update insert $new-relation preceding $spec/descendant-or-self::*[@id=$version-id]/asset
            else update insert $new-relation into $spec/descendant-or-self::*[@id=$version-id]
    let $login := data:close-access-to-database()
    return ""
};

declare function spec:store-version-status($spec,$val,$parentid){    
    let $node := $spec//*[@id=$parentid]/@status
    let $login := data:open-access-to-database()    
    let $up := 
        if ($node) then update value $node with $val
        else update replace $spec//*[@id=$parentid] 
             with <version id="{$parentid}" status="{$val}">{$spec//*[@id=$parentid]//*}</version>
    let $login := data:close-access-to-database()
    return $val
};

declare function spec:store-version-url($spec,$version-id,$node,$urls,$val){
    let $login := data:open-access-to-database()
    let $del := for $k in $node return update delete $k 
    let $up :=
        for $k in fn:reverse($urls)
        let $u := <address type="URL">{$k}</address>      
        return 
            if ($spec//*[@id=$version-id]/features) 
                then update insert $u following $spec//*[@id=$version-id]/features
            else if ($spec//*[@id=$version-id]/info[@type='description'])
                then update insert $u following $spec//*[@id=$version-id]/info[@type='description']
            else update insert $u following $spec//*[@id=$version-id]/date
    let $login := data:close-access-to-database()
    return $val
};




