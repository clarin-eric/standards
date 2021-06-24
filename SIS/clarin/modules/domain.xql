xquery version "3.0";

module namespace dm ="http://clarin.ids-mannheim.de/standards/domain-module";
import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";
import module namespace domain="http://clarin.ids-mannheim.de/standards/domain" at "../model/domain.xqm";

(:  Define domain-related functions
    @author margaretha
:)

(: Retrieve a domain node by its id :)
declare function dm:get-domain($id as xs:string){
    domain:get-domain($id)
};


(: Generate the list of domains :)
declare function dm:list-domains(){
    for $domain in $domain:domains
        let $domain-id := $domain/@id
        let $domain-name := $domain/name/text()
        let $domain-snippet := $domain/desc/text()     
    return
        <div>
            <li class="heading2">
               <button style="text-decoration:underline; color: grey; background-color:white; border:0px; padding:0px;" 
                onclick="openEditor('{$domain-id}')">{$domain-name}</button>
            </li>
            {if ($domain-name !='Other') then
               <span id="{$domain-id}" style="display:block">
                    <p>{$domain-snippet}</p>
                </span>
             else ()}
        </div>
};

