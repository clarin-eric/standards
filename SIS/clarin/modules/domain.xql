xquery version "3.0";

module namespace dm = "http://clarin.ids-mannheim.de/standards/domain-module";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace spec = "http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace domain = "http://clarin.ids-mannheim.de/standards/domain" at "../model/domain.xqm";

(:  Define domain-related functions
    @author margaretha
:)

(: Retrieve a domain node by its id :)
declare function dm:get-domain($id as xs:string) {
    domain:get-domain($id)
};

declare function dm:get-domain-by-name($name as xs:string) {
    domain:get-domain-by-name($name)
};

declare function dm:get-id-by-name($name as xs:string){
    domain:get-id-by-name($name)
};

(: get the name of the metadomain by passing a domain name or a domain ID :)
declare function dm:get-metadomain($nameOrId as xs:string){
       domain:get-metadomain($nameOrId) 
};

(: return a sequence of full domain nodes by passing the name of a metadomain, e.g. 'Annotation' :)
declare function dm:get-domains-by-metadomain($name as xs:string){
    domain:get-domains-by-metadomain($name)
};

declare function dm:get-domain-names-by-metadomain($name as xs:string){
    domain:get-domains-by-metadomain($name)/name
};


(: Generate the list of domains for the particular group :)
declare function dm:list-domains($group as xs:string) {
    for $domain in $domain:domains[@orderBy eq $group]
    let $domain-id := $domain/@id (: this is now always empty :)
    let $domain-name := $domain/name/text()
    let $domain-snippet := $domain/desc
        order by $domain-name
    return
        <li>
            <span class="list-text">{$domain-name}</span>
            {app:create-copy-button($domain-id,$domain-name,"Copy name to clipboard", "copied")}
            <span
                id="{$domain-id}"
                style="display:block">
                <p>{$domain-snippet}</p>
            </span>
        </li>
};

(: iterate across the groups of domains :)
declare function dm:list-domains-grouped() {
    for $group in distinct-values($domain:domains/@orderBy)
        order by $group
    return
        <li>
            <h2>{$group}</h2>
            <ul
                style="padding-left:15px">{dm:list-domains($group)}</ul>
        </li>
};

