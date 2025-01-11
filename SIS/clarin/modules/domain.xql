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
declare function dm:get-metadomain($nameOrId as xs:string) as xs:string {
   let $domain-name := domain:get-metadomain($nameOrId)
   let $metadomain := if ($domain-name eq '')
   then "Uncategorized"
   else $domain-name

    return $metadomain
};

(: return a sequence of full domain nodes by passing the name of a metadomain, e.g. 'Annotation' :)
declare function dm:get-domains-by-metadomain($name as xs:string) as element(domain)+ {
    domain:get-domains-by-metadomain($name)
};

declare function dm:get-domain-names-by-metadomain($name as xs:string){
    domain:get-domains-by-metadomain($name)/name
};


(: Generate the list of domains for the particular group :)
declare function dm:list-domains($group as xs:string) as element(li)+ {
    for $domain in domain:get-domains-by-metadomain($group)
       let $domain-id := $domain/@id
       let $domain-name := $domain/name/text()
       let $domain-snippet := $domain/desc
       let $recommendation-link := app:link(concat("views/recommended-formats-with-search.xq?domain=",
        $domain-id,"#searchRecommendation"))
        order by $domain-name
    return
        <li>
            <span class="list-text"><a href="{$recommendation-link}">{$domain-name}</a></span>
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
    for $group in domain:get-all-metadomains()
        order by $group
    return
        <li>
            <h2><a href="{dm:create-domain-group-recommendation-link($group)}">
                {$group}</a></h2>
                <p>{domain:get-metadomain-description($group)}</p>
            <ul
                style="padding-left:15px">{dm:list-domains($group)}</ul>
        </li>
};


declare function dm:create-domain-group-recommendation-link($group as xs:string) as xs:string {
        
    let $domain-ids := 
        for $id in domain:get-domains-by-metadomain($group)/@id
        return concat("domain=",$id)
    let $joined-domains := fn:string-join($domain-ids,"&amp;")
    
    return app:link(concat("views/recommended-formats-with-search.xq?",
        $joined-domains,"#filterRecommendation"))
};