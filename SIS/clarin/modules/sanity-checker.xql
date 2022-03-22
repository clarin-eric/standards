xquery version "3.1";

module namespace sc = "http://clarin.ids-mannheim.de/standards/sanity-checker";

import module namespace recommendation = "http://clarin.ids-mannheim.de/standards/recommendation-model"
at "../model/recommendation-by-centre.xqm";

import module namespace domain = "http://clarin.ids-mannheim.de/standards/domain" at "../model/domain.xqm";

declare function sc:get-recommendations-with-missing-or-unknown-domains() {
    for $r in $recommendation:centres
        let $centre := $r/header/filter/centre/text()
        for $format in $r/formats/format
            let $domain := $format/domain/text()
            let $domainObj := if ($domain) then domain:get-domain-by-name($domain) else ()
            return 
            if (not($domain) or fn:empty($domain) )
            then 
                <ul>
                    <li>
                        Centre : {$centre} <br/>
                        Format ID: {$format/data(@id)} <br/>
                    </li>    
                </ul>
            else if ($domainObj)
            then ()
            else 
                <ul>
                        <li>
                            Centre : {$centre} <br/>
                            Format ID: {$format/data(@id)} <br/>
                            Domain: {$domain}
                        </li>    
                    </ul>
            
};

declare function sc:get-recommendations-unknown-domains() {
    for $r in $recommendation:centres
        let $centre := $r/header/filter/centre/text()
        for $format in $r/formats/format
            let $domain := $format/domain/text()
            let $domainObj := if ($domain) then domain:get-domain-by-name($domain) else ()
            return
                if (not($domainObj) or fn:empty($domainObj) )
                then
                    <ul>
                        <li>
                            Centre : {$centre} <br/>
                            Format ID: {$format/data(@id)} <br/>
                        </li>    
                    </ul>
                else ()
};

declare function sc:get-recommendations-with-missing-or-unknown-levels() {
    for $r in $recommendation:centres
        let $centre := $r/header/filter/centre/text()
        for $format in $r/formats/format
            let $id := data($format/@id)
            let $level := $format/level/text()
            return
            (:missing level:)
                if (not($level) or fn:empty($level) )
                then
                    <ul>
                        <li>
                            Centre : {$centre} <br/>
                            Format ID: {$format/data(@id)} <br/>
                        </li>    
                    </ul>
                else  if ($level eq 'recommended' or $level eq 'acceptable' or $level eq 'deprecated')
                then ()
                else
                    <ul>
                        <li>
                            Centre : {$centre} <br/>
                            Format ID: {$format/data(@id)} <br/>
                            Level: {$level}
                        </li>    
                    </ul>
};


declare function sc:get-similar-recommendations() {
    for $r in $recommendation:centres
        let $centre := $r/header/filter/centre/text()
        let $domains := fn:distinct-values($r/formats/format/domain/text())
        let $ids := data($r/formats/format/@id)
        
        for $id in fn:distinct-values($ids)
            let $same-ids := $r/formats/format[@id=$id]
            let $isIdRepeated := fn:count($same-ids) >1
            return
                if ($isIdRepeated)
                then
                    for $d in $domains
                        let $same-domains := $same-ids[domain=$d]
                        let $isDomainRepeated := fn:count($same-domains) >1
                        
                        return 
                        if ($isDomainRepeated)
                        then 
                        <div style="border: 1px solid black">{sc:list-similar-recommendations($centre,$same-domains)}</div>
                        else ()
                else ()
};

declare function sc:list-similar-recommendations($centre, $formats){
    for $f in $formats
        let $comment := $f/comment
        return 
       <ul>
            <li>Centre : {$centre} <br/>
                   Format ID: {$f/data(@id)} <br/>
                   Domain: {$f/domain/text()} <br/>
                   Recommendations: {$f/level/text()} <br/>
                   Comment: {if($comment) then $comment else '[none]'}</li>

        </ul>
};