xquery version "3.0";

module namespace cm = "http://clarin.ids-mannheim.de/standards/centre-module";
import module namespace centre = "http://clarin.ids-mannheim.de/standards/centre" at "../model/centre.xqm";
import module namespace format = "http://clarin.ids-mannheim.de/standards/format" at "../model/format.xqm";
import module namespace recommendation = "http://clarin.ids-mannheim.de/standards/recommendation-model"
at "../model/recommendation-by-centre.xqm";
import module namespace data = "http://clarin.ids-mannheim.de/standards/data" at "../model/data.xqm";

import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace rf = "http://clarin.ids-mannheim.de/standards/recommended-formats" at "recommended-formats.xql";
import module namespace dm = "http://clarin.ids-mannheim.de/standards/domain-module" at "domain.xql";
import module namespace web="https://clarin.ids-mannheim.de/standards/web" at "../model/web.xqm";


declare function cm:get-centre($id) {
    centre:get-centre($id)
};

declare function cm:get-centre-by-research-infrastructure($ri as xs:string, $status as xs:string) {
    centre:get-centre-by-research-infrastructure($ri,$status)
};

declare function cm:count-number-of-centres-with-recommendations($centres){
    let $centre-with-recommendations :=
        for $c in $centres
             let $recommendations := cm:get-recommendations(data($c/@id))
             let $numOfRecommendations := count($recommendations/formats/format)
         return 
            if ($numOfRecommendations >0)
            then 1
            else 0
            
     return sum($centre-with-recommendations)
};

declare function cm:getLastUpdateCommitId($id){
    let $recommendation := recommendation:get-recommendations-for-centre($id)
    let $commitId := $recommendation/header/lastUpdateCommitID/text()
    let $githubLink := concat("https://github.com/clarin-eric/standards/commit/", $commitId)
    let $short-commitId := fn:substring($commitId,1,8)
    return <a href="{$githubLink}">{$short-commitId}</a>
};


declare function cm:getGithubCentreIssueLink($centre-id) {
    let $ghLink := 'https://github.com/clarin-eric/standards/issues/new?assignees=&amp;labels=centre+data%2C+templatic&amp;template=incorrect-missing-centre-recommendations.md&amp;title=Suggestion regarding the recommendations of centre ID="' 
    let $ghLink := concat($ghLink, $centre-id, '", webCommitId=',web:get-short-commitId())
    return $ghLink
};

declare function cm:print-statuses($status){
   let $statutes := centre:get-statutes()
   for $s in $statutes
   order by fn:lower-case($s)
   return
           if ($s eq $status)
           then
               (<option
                   value="{$s}"
                   selected="selected">{$s}</option>)
           else
               (<option
                   value="{$s}">{$s}</option>)
};

declare function cm:print-ri($centre-ri){
    for $ri in $centre-ri
    let $status := 
        if ($ri/@status ne "") 
        then concat(" (",data($ri/@status),")") 
        else () 
    return <li>{$ri/text(), $status}</li>
};

declare function cm:list-centre($sortBy,$statusFilter, $riFilter) {
    for $c in $centre:centres
        let $name := $c/name/text()
        let $id := data($c/@id)
        
        let $ris := 
            for $ri in $c/nodeInfo/ri
            let $status := data($ri/@status)
            return 
                if ($status ne "") then ($ri, concat(" (", $status,")"),<br/>) 
                else ($ri,<br/>)
            
        let $combinedStatuses := fn:string-join($c/nodeInfo/ri/@status,",")    
        let $statuses :=  fn:tokenize($combinedStatuses, ",")
        order by
        
        if ($sortBy eq 'name')
        then fn:lower-case($name)
        else if ($sortBy eq 'ri')
        then fn:lower-case($ris)
        else if ($sortBy eq 'id')
        then (fn:lower-case($id))
        else (fn:lower-case($id))
        
        return
            
        if ($statusFilter)
        then 
            if (fn:contains($statuses, $statusFilter))
            then cm:filter-by-ri($id, $name, $ris, $riFilter)
            else ()
        else (cm:filter-by-ri($id, $name, $ris, $riFilter))
};


declare function cm:filter-by-ri($id, $name, $ris, $riFilter){
    if ($riFilter)
    then 
        if (fn:contains($ris,$riFilter))
        then   cm:print-centre-row($id, $name, $ris)
        else ()
    else(cm:print-centre-row($id, $name, $ris))
};

declare function cm:print-centre-row($id, $name, $ri){
    <tr>
        <td class="recommendation-row"><a href="{app:link(concat("views/view-centre.xq?id=", $id))}">{$id}</a></td>
        <td class="recommendation-row">{$name}</td>
        <td class="recommendation-row">{$ri}</td>
    </tr>
};

declare function cm:get-recommendations($id) {
    recommendation:get-recommendations-for-centre($id)
};

declare function cm:get-centre-info($id,$lang) {
    let $check-format-tag := cm:parse-format-tag(cm:get-recommendations($id)/info)
    
    let $centre-info := 
        if ($id)
        then cm:get-recommendations($id)/info[@xml:lang =$lang]
        else ()
    
   return
        if ($centre-info) 
        then $centre-info 
        else cm:get-default-info($id)        
};

declare function cm:get-default-info($id){
    let $en-info := cm:get-recommendations($id)/info[@xml:lang ="en"]
    return
        if ($en-info)
        then $en-info
        else cm:get-recommendations($id)/info[not(@xml:lang)]
};

declare function cm:parse-format-tag($centre-info){
    let $login := data:open-access-to-database()    
    let $check := 
        for $format in $centre-info/p/format
        return update replace $format with 
        <a href="{concat("/>//views/view-format.xq?id=", $format/text())}">
        {$format/text()}</a>
     let $login := data:close-access-to-database()
     return ""
};

declare function cm:print-curation($respStmt,$language){
    if ($respStmt)
    then (
        <div>
            <span class="heading">Curator: </span>
            <span>{$respStmt/curator/text()}</span>
            {if (empty($respStmt/github/text()))
              then ()
              else (
              " (",<a href="{$respStmt/github/text()}">github</a>,")")
            }
        </div>,
        <div>
            <span class="heading">Review date: </span>
            <span>{format-date($respStmt/reviewDate/text(), 
        "[MNn] [D], [Y]", $language, (), () )}</span>
        </div>
    )
    else (
        <div>
             <span  class="heading" style="color:darkred">Warning: </span> 
            <span style="color:darkred">The recommendations have not been curated yet.</span>
        </div>
    )
};


declare function cm:print-recommendation-rows($recommendation, $centre-id, $sortBy,
$language) {
    for $format in $recommendation/formats/format
        let $format-id := data($format/@id)
        let $format-obj := format:get-format($format-id)
        let $format-abbr := $format-obj/titleStmt/abbr/text()
        let $level := $format/level/text()
        let $domainName := $format/domain/text()
        let $domain :=
            if ($domainName) then
                dm:get-domain-by-name($domainName)
            else ()
            
        order by
        if ($sortBy = 'format') then
            (if ($format-abbr) then fn:lower-case($format-abbr) else fn:lower-case(fn:substring($format-id,2)))
        else
            if ($sortBy = 'domain') then
                $domainName
            else
                if ($sortBy = 'recommendation') then
                    $level
                else (:by format:)
                    (if ($format-abbr) then fn:lower-case($format-abbr) else fn:lower-case(fn:substring($format-id,2)))
    return 
        rf:print-recommendation-row($format, $centre-id, $domain, $language, fn:true(), fn:false())
};
