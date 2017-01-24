xquery version "3.0";

module namespace vsb="http://clarin.ids-mannheim.de/standards/view-sb";

import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

declare function vsb:get-sb-links($id, $abbr){

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

(:for $index in functx:index-of-string($id,"-")
        let $id := fn:substring($id,1,$index -1)
        let $link := app:link(concat("views/view-sb.xq?id=",$id))
        return $link  :)  
 
};