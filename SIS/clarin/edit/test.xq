import module namespace data = "http://clarin.ids-mannheim.de/standards/data" at "../model/data.xqm";
(:import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";:)
import module namespace f = "http://clarin.ids-mannheim.de/standards/module/form" at "../edit/edit-form.xq";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";
(: Data Collection :)
let $data := collection("/db/apps/clarin/data/specifications")/spec
(:<div>{$data//*[@id="SpecCes"]}</div>:)
   
(:let $descs := $data/descendant-or-self::info[@type ="description"]/p 

let $login := data:open-access-to-database()
let $update := 
    for $id in $descs/@id        
        return update delete $id 
    
let $login := data:close-access-to-database()
   
return <div> 


<div>{
    for $d in $descs
    let $content := $d
    return $content} </div>
 </div>:)
 
let $login := data:open-access-to-database() 
let $up := 
    for $p in $data/part
    return update insert attribute id{f:generateRandomId(())} into $p 

let $login := data:close-access-to-database()

return <div> {
    for $p in $data/part
    return <p>{data($p/ancestor::spec/@id)}</p>
    }
    </div>
 
    



 