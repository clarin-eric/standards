xquery version "3.0";

module namespace domain="http://clarin.ids-mannheim.de/standards/domain";

(: Define the methods for accessing functional domain data
    @author piotr banski
    @author margaretha
:)

declare variable $domain:domains := doc('/db/apps/clarin/data/domains.xml')/domains/domain;
    

(: Select a domain by id :)
declare function domain:get-domain($id as xs:string){
    $domain:domains[@id=$id]
};

(: Select a domain by name :)
declare function domain:get-domain-by-name($name as xs:string){
    $domain:domains[name=$name]
};