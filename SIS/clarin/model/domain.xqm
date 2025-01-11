xquery version "3.1";

module namespace domain="http://clarin.ids-mannheim.de/standards/domain";

(: Define the methods for accessing functional domain data
    @author piotr banski
    @author margaretha
:)

declare variable $domain:domains as element(domain)+ := doc('/db/apps/clarin/data/domains.xml')/domains/domain;
declare variable $domain:metadomains as element(metadomain)+ := doc('/db/apps/clarin/data/domains.xml')/domains/metadomain;
declare variable $domain:names  as text()+ := $domain:domains/name/text();
(:declare variable $domain:metadomain-names  as text()+ := $domain:metadomains/name/text();:)

(: Select a domain by id :)
declare function domain:get-domain($id as xs:string) as element(domain) {
    $domain:domains[@id=$id]
};

(: Select a domain by name :)
declare function domain:get-domain-by-name($name as xs:string) as element(domain) {
    $domain:domains[name=$name]
};

(: Query the internal domain ID by providing a string name :)
declare function domain:get-id-by-name($name as xs:string) as xs:integer {
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

(: return a sequence of metadomain names together with "Uncategorized".
   note that this presents the real thing: the actually used metadomains, 
   rather than those that are merely declared at the top; there should be a 
   consistency check for the legality of the values of @orderBy :)
declare function domain:get-all-metadomains() as xs:string+ {
  distinct-values($domain:domains/@orderBy), "Uncategorized"
};

(: Select a domain by name :)
declare function domain:get-metadomain-description($name as xs:string) as xs:string {
   if ($name eq 'Uncategorized') 
   then
     "(Do let us know if you can identify a sensible metadomain for the domains listed here.)"
   else
     ($domain:metadomains[name=$name]/desc)[1]
};




