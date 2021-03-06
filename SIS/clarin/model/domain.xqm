xquery version "3.0";

module namespace domain="http://clarin.ids-mannheim.de/standards/domain";

import module namespace data="http://clarin.ids-mannheim.de/standards/data" at "data.xqm";

(: Define the methods for accessing functinal domain data
   @author margaretha
:)

declare variable $domain:domains := 
    for $domain in doc('/db/apps/clarin/data/domains.xml')/domains/domain
    return $domain;

(: Select a domain by id :)
declare function domain:get-domain($id as xs:string){
    $domain:domains[@id=$id]
};