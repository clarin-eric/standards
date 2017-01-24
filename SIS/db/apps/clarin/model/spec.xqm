xquery version "3.0";

module namespace spec="http://clarin.ids-mannheim.de/standards/specification";

import module namespace data = "http://clarin.ids-mannheim.de/standards/data" at "../model/data.xqm";
import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

declare variable $spec:specs := collection("/db/apps/clarin/data/specifications")/spec[not(data(@display)='hide')];
declare variable $spec:reviews := collection("/db/apps/clarin/data/review")/spec;

declare function spec:sort-specs(){
    for $spec in $spec:specs
    order by app:name($spec)
    return $spec
};

declare function spec:get-spec($id as xs:string){
    $spec:specs/descendant-or-self::node()[@id=$id]
};

declare function spec:sum(){
    count($spec:specs)
};

declare function spec:get-targets(){   
    for $spec in $spec:specs         
    return data($spec/descendant::version/relation/@target) 
};

declare function spec:get-standardBodies(){
    for $spec in $spec:specs         
    return data($spec/@standardSettingBody)
};

declare function spec:get-topics($spec){
    tokenize(data($spec/@topic),' ')
};

declare function spec:store($prefix,$node,$spec){
    let $login := data:open-access-to-database()
    let $c := count($spec/info)
    let $store := 
        if ($prefix="p") then 
            if ($spec/part) then update insert $node following $spec/part
            else update insert $node following $spec/info[$c]
        else if ($prefix="v") then
            if ($spec/version) then update insert $node following $spec/version
            else update insert $node following $spec/info[$c]
        else()
    let $login := data:close-access-to-database()
    return ""
};

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

declare function spec:store-review($file,$spec){
    let $login := data:open-access-to-database()
    let $store := xmldb:store($data:review-path,$file,$spec) 
    let $login := data:close-access-to-database()
    return ""
};

declare function spec:update-spec($node,$val){
    let $login := data:open-access-to-database()   
    let $up := update replace $node with $val
    let $login := data:close-access-to-database()
    return $val
};

declare function spec:remove-element($node){
    let $login := data:open-access-to-database()
    let $up := update delete $node
    let $login := data:close-access-to-database()
    return ''
};