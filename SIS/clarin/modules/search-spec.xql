xquery version "3.0";

module namespace search ="http://clarin.ids-mannheim.de/standards/search-spec";
import module namespace xsd = "http://clarin.ids-mannheim.de/standards/schema" at "../model/schema.xqm";
import module namespace spec="http://clarin.ids-mannheim.de/standards/specification" at "../model/spec.xqm";

import module namespace f = "http://clarin.ids-mannheim.de/standards/module/form" at "../edit/edit-form.xq";

import module namespace app="http://clarin.ids-mannheim.de/standards/app" at "../modules/app.xql";
import module namespace tm ="http://clarin.ids-mannheim.de/standards/topic-module" at "../modules/topic.xql";
import module namespace sbm="http://clarin.ids-mannheim.de/standards/sb-module" at "../modules/sb.xql";

import module namespace functx = "http://www.functx.com" at "../resources/lib/functx-1.0-doc-2007-01.xq";

(: Define functions for searching standards 
   @author margaretha
:)

(: Search standards :)
declare function search:get-results($query, $topic, $sb, $status, $usedInCLARINCenter, $CLARINapproved){
    let $tokens := fn:tokenize($query, " ")          
    let $spec-group := 
        if (count($tokens)>0)
        then search:spec-by-query-and-filter($tokens, $topic, $sb, $status)
        else if ($topic)
        then search:by-topic($spec:specs,$topic,$sb,$status)            
        else if ($sb)
        then search:by-sb($spec:specs,$sb,$status)
        else if ($status)
        then search:by-status($spec:specs,$status)
        else $spec:specs
        
    return search:filter-clarin($spec-group,$usedInCLARINCenter,$CLARINapproved)
};

declare function search:spec-by-query-and-filter($query-tokens, $topic, $sb, $status){
              
    let $spec-by-query :=
        for $token in $query-tokens
            let $specs-by-title := $spec:specs[contains(lower-case(titleStmt/title/text()),lower-case($token))]/@id
            let $specs-by-abbr := $spec:specs[contains(lower-case(titleStmt/abbr/text()),lower-case($token))]/@id
            let $specs-by-versionnummer := $spec:specs/descendant-or-self::version[contains(versionNumber,$token)]/@id
            let $specs-by-scope := $spec:specs[contains(lower-case(/scope),lower-case($token))]/@id
            let $specs-by-keyword := $spec:specs[contains(lower-case(fn:string-join(keyword/text()," ")),lower-case($token))]/@id 
            let $specs-by-topic := $spec:specs[contains(lower-case(@topic),lower-case($token))]/@id
            let $specs-by-sb := $spec:specs[contains(lower-case(@standardSettingBody),lower-case($token))]/@id     
        return ($specs-by-versionnummer,$specs-by-title,$specs-by-abbr,$specs-by-keyword,$specs-by-scope,$specs-by-topic,$specs-by-sb)
             
    let $spec-group := 
        for $id in fn:distinct-values($spec-by-query)
        return spec:get-spec($id)
        
   return
        (: Filters :)
        if ($topic)
        then search:by-topic($spec-group,$topic,$sb,$status)            
        else if ($sb)
        then search:by-sb($spec-group,$sb,$status)            
        (: status :)
        else if ($status)         
        then search:by-status($spec-group,$status)
        else $spec-group
};

(: List status types :)
declare function search:list-status($selectedStatus){
    f:list-options(xsd:get-statuses(),$selectedStatus)
};

(: Search standards by topic:)
declare function search:by-topic($spec-group,$topic,$sb,$status){
    if ($sb)
    then 
        if ($status)
        (: topic and sb and status :)
        then $spec-group[contains(@topic,$topic) and @standardSettingBody=$sb 
            and descendant::node()[contains(@status,$status)]]
        (: topic and sb :)
        else $spec-group[contains(@topic,$topic) and @standardSettingBody=$sb]
    else if ($status)
    (: topic and status :)
    then $spec-group[contains(@topic,$topic) and descendant::node()[contains(@status,$status)]]
    (: topic :)            
    else $spec-group[contains(@topic,$topic)]
};

(: Search standards by standard body :)
declare function search:by-sb($spec-group,$sb,$status){
    (: sb and status :)
    if ($status)
    then 
        $spec-group[@standardSettingBody=$sb and descendant::node()[contains(@status,$status)]]
    (: sb :)
    else $spec-group[@standardSettingBody=$sb]
};

declare function search:by-status($spec-group,$status){
    $spec-group[descendant::node()[contains(@status,$status)]]
};

declare function search:filter-clarin($spec-group,$usedInCLARINCenter,$clarinApproval){         
    if ($usedInCLARINCenter)
    then 
        if ($clarinApproval)
        (: $usedInCLARINCenter and CLARINapproved :)
        then $spec-group[descendant-or-self::version[@usedInCLARINCenter and @CLARINapproved]]
        (: $usedInCLARINCenter :)
        else $spec-group[descendant-or-self::version/@usedInCLARINCenter]
    (: CLARINapproved :)
    else if ($clarinApproval)
    then $spec-group[version/@CLARINapproved]
    (: No Clarin filters :)
    else $spec-group
};

(: Print the results:)
declare function search:print-results($submitted, $results){
    if ($submitted)
    then (<div><span class="heading">Standards found: </span>{count($results)}</div>,
          <ol>{ for $spec in $results
                    let $id := data($spec/ancestor-or-self::*/@id)
                    let $spec-name := $spec/titleStmt/title/text()              					
                return 
                    if (count($id) > 1)
                    then <li><a href="{app:link(string-join(("views/view-spec.xq?id=",$id[1],"#",$id[2])))}">{$spec/versionNumber}</a></li>
                    else <li><a href="{app:link(concat("views/view-spec.xq?id=",$id))}">{$spec/titleStmt/title/text()}</a></li>
          }</ol>
    )
    else ''
};
