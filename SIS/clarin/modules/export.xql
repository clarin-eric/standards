xquery version "3.0";

module namespace em = "http://clarin.ids-mannheim.de/standards/export";

import module namespace recommendation = "http://clarin.ids-mannheim.de/standards/recommendation-model"
at "../model/recommendation-by-centre.xqm";
import module namespace app = "http://clarin.ids-mannheim.de/standards/app" at "app.xql";
import module namespace dm = "http://clarin.ids-mannheim.de/standards/domain-module" at "../modules/domain.xql";

declare function em:list-domains($domainIds as xs:string*){
    for $id in $domainIds
        let $domain := dm:get-domain($id)
        let $domainName := $domain/name/text()
    return
        if ($domainName) then
            <domain>{$domainName}</domain>
        else ()
};

declare function em:export-table($ri, $centre, $domainId, $requestedLevel, 
    $nodes, $filename, $page,$centreInfo) {
    
    let $filter :=
        (if ($centre) then
            <centreID>{$centre}</centreID>
        else (),
        em:list-domains($domainId),
        if ($requestedLevel) then
            <level>{$requestedLevel}</level>
        else
            ())
        
    let $rows :=
        for $row in $nodes
        let $comment := $row/td[5]//comment
        return
            <format id="{$row/td[1]/@id}">
                {
                    if ($centre eq "") then
                        <centreID>{$row/td[2]/a/text()}</centreID>
                    else
                        (),
                    if (count($domainId) ne 1) then
                        (:<domain
                                id="{$row/td[3]/@id}">{$row/td[3]/text()}</domain>:)
                        <domain>{$row/td[3]/span/text()}</domain>
                    else (),
                    if ($requestedLevel eq "") then
                        (<level>{$row/td[4]/text()}</level>)
                    else
                        (),
                    if ($comment) then $comment else ()
                }
            
            </format>
        
    let $quote := "&#34;"    
    let $content-disposition := concat("attachment; filename=",
          $quote, $filename, $quote)
    
    return
       (         
          <rest:response>
            <http:response status="200">
              <http:header name="Content-Disposition" value='{$content-disposition}'/>
              <http:header name="Content-Type" value="application/xml;charset=utf-8"/>
            </http:response>
          </rest:response>
        ,
        <recommendation xsi:noNamespaceSchemaLocation="https://clarin.ids-mannheim.de/standards/schemas/recommendation.xsd">
            <header>
                <title>CLARIN Standards Information System (SIS) export</title>
                <url>{app:link($page)}</url>
                <exportDate>{fn:current-dateTime()}</exportDate>
                <filter>
                {if($ri) then <ri>{$ri}</ri> else ()}
                {$filter}
                </filter>
            </header>
            {$centreInfo}
            <formats>{$rows}</formats>
        </recommendation>
      )
};


declare function em:download-template($centre-id,$filename){
    let $filename := fn:replace($filename,":","-")
    let $quote := "&#34;"    
    let $content-disposition := concat("attachment; filename=",
          $quote, $filename, $quote)
    let $recommendation := recommendation:get-recommendations-for-centre($centre-id)

    return
      (         
          <rest:response>
            <http:response status="200">
              <http:header name="Content-Disposition" value='{$content-disposition}'/>
              <http:header name="Content-Type" value="application/xml;charset=utf-8"/>
            </http:response>
          </rest:response>
        ,
        <recommendation xsi:noNamespaceSchemaLocation="https://clarin.ids-mannheim.de/standards/schemas/recommendation.xsd">
            <header>
                <title>CLARIN Standards Information System (SIS) export</title>
                <url>{app:link(concat("/views/view-centre.xq?id=",$centre-id))}</url>
                <exportDate>{fn:current-dateTime()}</exportDate>
                <filter>
                   <centreID>{$centre-id}</centreID>
                </filter>
            </header>
            {$recommendation/formats}    
        </recommendation>
      )
};