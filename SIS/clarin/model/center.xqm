xquery version "3.0";

module namespace center="http://clarin.ids-mannheim.de/standards/center";

import module namespace data="http://clarin.ids-mannheim.de/standards/data" at "data.xqm";

(: Define the methods for accessing center data
   @author margaretha
:)

declare variable $center:centers := doc('/db/apps/clarin/data/centers.xml')/centers/center;
    
declare function center:get-center($id as xs:string){
    $center:centers[@id=$id]
};

