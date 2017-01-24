xquery version "3.0";

module namespace search ="http://clarin.ids-mannheim.de/standards/search-spec";
import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";
import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";

import module namespace f = "http://clarin.ids-mannheim.de/standards/module/form" at "../edit/edit-form.xq";

import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace tm ="http://clarin.ids-mannheim.de/standards/topic-module" at "../modules/topic.xql";
import module namespace sbm="http://clarin.ids-mannheim.de/standards/sb-module" at "../modules/sb.xql";

import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";


declare function search:list-status($selectedStatus){
    f:list-options(xsd:get-statuses(),$selectedStatus)
};

declare function search:by-topic($topic,$sb,$status){
    let $specs-by-topic := $spec:specs[contains(@topic,$topic)]    
    return 
        if ($sb and $status)
        then ($specs-by-topic[@standardSettingBody=$sb and descendant::node()[contains(@status,$status)]]/@id,
              $specs-by-topic[@standardSettingBody=$sb]/@id, 
              $specs-by-topic[descendant::node()[contains(@status,$status)]]/@id,
              $specs-by-topic/@id)
        else if ($sb)
        then ($specs-by-topic[@standardSettingBody=$sb]/@id, $specs-by-topic/@id)
        else if ($status)
        then ($specs-by-topic[descendant::node()[contains(@status,$status)]]/@id, $specs-by-topic/@id)
        else $specs-by-topic/@id
};

declare function search:by-sb($sb,$status){
    let $specs-by-sb := $spec:specs[@standardSettingBody=$sb]
    return 
        if ($status)
        then($specs-by-sb[descendant::node()[contains(@status,$status)]]/@id, $specs-by-sb/@id)
        else $specs-by-sb/@id
};

declare function search:get-results($query, $topic, $sb, $status){    
    let $tokens := fn:tokenize($query, " ")
          
    let $results := 
        if (count($tokens)>0)
        then
            for $token in $tokens
                let $specs-by-title := $spec:specs[contains(lower-case(titleStmt/title/text()),lower-case($token))]/@id
                let $specs-by-abbr := $spec:specs[contains(lower-case(titleStmt/abbr/text()),lower-case($token))]/@id
                let $specs-by-versionnummer := $spec:specs/descendant-or-self::version[contains(versionNumber,$token)]/@id
                let $specs-by-scope := $spec:specs[contains(lower-case(/scope),lower-case($token))]/@id
                let $specs-by-keyword := $spec:specs[contains(lower-case(fn:string-join(keyword/text()," ")),lower-case($token))]/@id               
               
                let $spec-group := ($specs-by-versionnummer,$specs-by-title,$specs-by-abbr)
                let $spec-by-group-and-topic := 
                    if ($topic) then $spec:specs[contains(@topic,$topic) and functx:is-value-in-sequence(@id, $spec-group)]/@id
                    else $spec:specs[contains(lower-case(@topic),lower-case($token)) and functx:is-value-in-sequence(@id, $spec-group)]/@id
                let $spec-by-group-and-sb := 
                    if ($sb) then $spec:specs[@standardSettingBody=$sb and functx:is-value-in-sequence(@id, $spec-group)]/@id
                    else $spec:specs[contains(lower-case(@standardSettingBody),lower-case($token)) and functx:is-value-in-sequence(@id, $spec-group)]/@id
                 
                let $spec-by-group-and-status := 
                    if ($status) then $spec:specs[functx:is-value-in-sequence(@id,($spec-by-group-and-topic,$spec-by-group-and-sb)) 
                    and descendant::node()[contains(@status,$status)]]/@id
                    else ()
                                    
                let $specs-by-topic := $spec:specs[contains(lower-case(@topic),lower-case($token))]/@id
                let $specs-by-sb := $spec:specs[contains(lower-case(@standardSettingBody),lower-case($token))]/@id                
                
            return ($specs-by-versionnummer,$spec-by-group-and-status,$spec-by-group-and-topic,$spec-by-group-and-sb,
                $specs-by-title,$specs-by-abbr,$specs-by-keyword,$specs-by-scope,$specs-by-topic,$specs-by-sb)
                        
        else if ($topic)
        then search:by-topic($topic,$sb,$status)            
        else if ($sb)
        then search:by-sb($sb,$status)
        else if ($status)
        then $spec:specs[descendant::node()[contains(@status,$status)]]/@id
        else "" 
        
    let $results-by-status := 
        if ($status)
        then ()
        else ()
    
    return 
        for $id in fn:distinct-values($results)
        return spec:get-spec($id)
        
};

declare function search:print-results($results){
    <ol>{
        for $spec in $results
            let $id := data($spec/ancestor-or-self::*/@id)
            let $spec-name := $spec/titleStmt/title/text()              					
        return 
            if (count($id) > 1)
            then <li><a href="{app:link(string-join(("views/view-spec.xq?id=",$id[1],"#",$id[2])))}">{$spec/versionNumber}</a></li>
            else <li><a href="{app:link(concat("views/view-spec.xq?id=",$id))}">{$spec/titleStmt/title/text()}</a></li>
    }</ol>
};
