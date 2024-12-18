xquery version "3.1";

module namespace domain="http://clarin.ids-mannheim.de/standards/domain";

(: Define the methods for accessing functional domain data
    @author piotr banski
    @author margaretha
:)

declare variable $domain:domains := doc('/db/apps/clarin/data/domains.xml')/domains/domain;
declare variable $domain:names := $domain:domains/name/text();    

(: Select a domain by id :)
declare function domain:get-domain($id as xs:string){
    $domain:domains[@id=$id]
};

(: Select a domain by name :)
declare function domain:get-domain-by-name($name as xs:string){
    $domain:domains[name=$name]
};

(: Query the internal domain ID by providing a string name :)
declare function domain:get-id-by-name($name as xs:string){
    data($domain:domains[name=$name]/@id)
};

(: get the name of the metadomain by passing a domain name or a domain ID :)
declare function domain:get-metadomain($nameOrId as xs:string){
       data (($domain:domains[name eq $nameOrId]/@orderBy, $domain:domains[@id eq $nameOrId]/@orderBy)) 
};

(: return a sequence of full domain nodes by passing the name of a metadomain, e.g. 'Annotation' :)
declare function domain:get-domains-by-metadomain($name as xs:string) as element(domain)+ {
  if ($name eq 'Uncategorized') 
  then
    $domain:domains[count(@orderBy) eq 0] (:add also @orderBy eq '' ? Let it bug out, rather... :)
  else
    $domain:domains[@orderBy eq $name]
};

(: return a sequence of metadomain names together with "Uncategorized" :)
declare function domain:get-all-metadomains() as xs:string+ {
   (:distinct-values($domain:domains/@orderBy):)
   (:distinct-values($domain:domains/@orderBy)[string-length() gt 0], "Uncategorized":)
   distinct-values($domain:domains/@orderBy), "Uncategorized"
};





