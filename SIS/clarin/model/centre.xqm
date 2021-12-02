xquery version "3.0";

module namespace centre="http://clarin.ids-mannheim.de/standards/centre";

(: Define the methods for accessing centre data
   @author margaretha
:)

declare variable $centre:centres := doc('/db/apps/clarin/data/centres.xml')/centres/centre;
    
declare function centre:get-centre($id as xs:string){
    $centre:centres[@id=$id]
};

