xquery version "3.0";

module namespace centre="http://clarin.ids-mannheim.de/standards/centre";

(: Define the methods for accessing centre data
   @author margaretha
:)

declare variable $centre:centres := doc('/db/apps/clarin/data/centres.xml')/centres/centre;
    
declare function centre:get-centre($id as xs:string){
    $centre:centres[@id=$id]
};

declare function centre:get-statutes(){
let $statuses := fn:distinct-values($centre:centres/nodeInfo/ri/@status)
let $flat :=
    for $status in $statuses
    return
        if (fn:contains($status,","))
        then (
            for $s in fn:tokenize($status,",")
            return fn:normalize-space($s)
         )
        else fn:normalize-space($status)

return fn:distinct-values($flat)
};
