xquery version "3.0";

module namespace centre="http://clarin.ids-mannheim.de/standards/centre";
import module namespace recommendation = "http://clarin.ids-mannheim.de/standards/recommendation-model" 
at "recommendation-by-centre.xqm";

(: Define the methods for accessing centre data
   @author margaretha
:)

(:declare variable $centre:centres := doc('/db/apps/clarin/data/centres.xml')/centres/centre;:)
declare variable $centre:centres := $recommendation:centres/header/centre;
declare variable $centre:ids := data($centre:centres/@id);
declare variable $centre:names := $centre:centres/name/text();
    
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

declare function centre:get-centre-ids-by-ri($ri as xs:string){
    data($centre:centres[nodeInfo/ri=$ri]/@id)
};

declare function centre:get-centre-by-research-infrastructure($ri as xs:string,
    $status as xs:string){
    for $c in $centre:centres[nodeInfo/ri=$ri]
        let $c-status :=  $c/nodeInfo/ri/@status
    return
        if (contains($c-status,$status))
        then $c
        else ()
};

declare function centre:get-distinct-research-infrastructures(){
    fn:distinct-values($centre:centres/nodeInfo/ri)
};

declare function centre:get-deposition-centres($ri){
    $centre:centres[nodeInfo/ri=$ri and xs:boolean(@deposition)]
};